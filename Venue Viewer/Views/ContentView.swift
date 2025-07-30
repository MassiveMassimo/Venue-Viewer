import SwiftUI

// MARK: - Sheet State Management
enum SheetState {
    case controls
    case landmarkDetail
    case navigation
    case none
}

struct ContentView: View {
    @State private var viewModel = NavigationViewModel()
    @State private var currentSheet: SheetState = .controls
    @State private var isTrackingViewActive = false
    @State private var sheetDetent: PresentationDetent = .height(120)
    
    private var shouldShowSheet: Bool {
        switch currentSheet {
        case .controls:
            return !viewModel.isInNavigationMode
        case .landmarkDetail:
            return !viewModel.isInNavigationMode
        case .navigation:
            return viewModel.isInNavigationMode
        case .none:
            return false
        }
    }

    private func setupViewModelHooks() {
        viewModel.onSheetStateChanged = { newState in
            self.currentSheet = newState
        }
        viewModel.onLandmarkDetailDismissed = {
            // Handle additional cleanup when landmark detail is dismissed
        }
    }
    
    @ViewBuilder
    private func currentSheetContent() -> some View {
        switch currentSheet {
        case .controls:
            ControlsSheetView(viewModel: viewModel, sheetDetent: $sheetDetent)
                .presentationDetents([.height(120), .medium, .large], selection: $sheetDetent)
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled(true)
        case .landmarkDetail:
            LandmarkDetailSheet(
                landmark: viewModel.selectedLandmark,
                viewModel: viewModel
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        case .navigation:
            NavigationBottomSheetView(viewModel: viewModel)
                .presentationDetents([.height(180)])
                .presentationBackgroundInteraction(.enabled)
                .presentationDragIndicator(.visible)
        case .none:
            EmptyView()
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                MapCanvasView(viewModel: viewModel)
                    .ignoresSafeArea(.all)
                    .sheet(isPresented: .constant(shouldShowSheet)) {
                        if currentSheet == .landmarkDetail {
                            currentSheet = .controls
                        }
                    } content: {
                        currentSheetContent()
                    }
                
                VStack {
                    if viewModel.isInNavigationMode {
                        NavigationHeaderView(viewModel: viewModel)
                        Spacer()
                    } else {
                        Spacer()
                        Button(action: { isTrackingViewActive = true }) {
                            Image(systemName: "location.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .padding(12)
                                .background(
                                    Circle()
                                        .fill(Color(.systemBackground))
                                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                )
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 50)
                    }
                }
            }
            .onChange(of: viewModel.selectedDestination) { _, _ in
                viewModel.clearResults()
            }
            .onChange(of: viewModel.selectedStartingPoint) { _, _ in
                viewModel.clearResults()
            }
            .onChange(of: viewModel.selectedLandmark) { _, newLandmark in
                if !viewModel.isInNavigationMode {
                    currentSheet = newLandmark != nil ? .landmarkDetail : .controls
                }
            }
            .onChange(of: viewModel.isInNavigationMode) { _, isInNavigation in
                if isInNavigation {
                    currentSheet = .navigation
                } else {
                    currentSheet = .controls
                }
            }
            .navigationDestination(isPresented: $isTrackingViewActive) {
                LocationTrackingView()
            }
            .onAppear {
                setupViewModelHooks()
            }
        }
    }
}

// MARK: - Supporting Views

struct ControlsSheetView: View {
    @Bindable var viewModel: NavigationViewModel
    @Binding var sheetDetent: PresentationDetent
    
    var body: some View {
        VStack(spacing: 16) {
            // Title
            HStack {
                Text("Office Navigator")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal, 20)
            
            // Navigation Controls
            VStack(spacing: 12) {
                LocationPicker(
                    title: "From:",
                    selection: $viewModel.selectedStartingPoint,
                    landmarks: viewModel.landmarks
                )
                
                LocationPicker(
                    title: "To:",
                    selection: $viewModel.selectedDestination,
                    landmarks: viewModel.landmarks
                )
                
                if viewModel.resultDistance != 0 {
                    RouteInfoView(distance: viewModel.resultDistance)
                        .animation(.easeInOut, value: viewModel.resultDistance)
                }
                
                FindRouteButton(action: viewModel.findRoute)
                    .disabled(!viewModel.canFindRoute)
                    .opacity(viewModel.canFindRoute ? 1 : 0.6)
                    .animation(.easeInOut, value: viewModel.canFindRoute)
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .background(Color(.systemBackground))
        .onChange(of: viewModel.resultDistance) { oldValue, newValue in
            // When a route is found (distance transitions from 0 to nonzero), minimize the sheet
            if oldValue == 0 && newValue != 0 {
                sheetDetent = .height(120)
            }
        }
    }
}

struct FindRouteButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "point.topleft.down.curvedto.point.bottomright.up")
                Text("Find Route")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .font(.system(size: 18))
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.blue)
            )
            .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
