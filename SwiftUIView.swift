import SwiftUI

// this beautiful graph was written by CCP certified chinese ai

struct GraphView: View {
    @Binding var data: [Double]
    
    // --- Computed Properties ---
    private var maxDataValue: Double {
        data.max() ?? 1.0
    }
    
    private var minDataValue: Double {
        data.min() ?? 0.0
    }
    
    private var dataRange: Double {
        let range = maxDataValue - minDataValue
        return range == 0 ? 1.0 : range
    }
    
    private var hasNegativeData: Bool {
        var a = 0.0
        for i in 0..<data.count {
            a += data[i]
        }
       // data.contains { $0 < 0 }
        
        return a < 0
    }
    
    // --- State ---
    @State private var trimAmount: CGFloat = 0.0
    @State private var warningPulse: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Background Card
            backgroundCard
            
            // Warning Indicator
            if hasNegativeData {
                warningIndicator
            }
            
            // Graph Content
            graphContent
        }
        .frame(width: 350, height: 250)
        .onAppear {
            animateOnAppear()
        }
        .onChange(of: data) { oldValue, newValue in
            animateOnDataChange()
        }
    }
    
    // MARK: - Subviews
    
    private var backgroundCard: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(backgroundGradient)
            .overlay(backgroundStroke)
            .shadow(color: shadowColor, radius: shadowRadius, y: 5)
            .scaleEffect(hasNegativeData ? warningPulse : 1.0)
    }
    
    private var warningIndicator: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
                .font(.caption)
            Text("Negative Values")
                .font(.caption)
                .foregroundColor(.red)
        }
        .padding(8)
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
        .position(x: 70, y: 25)
    }
    
    private var graphContent: some View {
        Group {
            if !data.isEmpty {
                GeometryReader { geometry in
                    let size = geometry.size
                    
                    ZStack {
                        // Grid
                        gridLines(in: size)
                        
                        // Graph Elements
                        if data.count > 1 {
                            shadedArea(in: size)
                            lineGraph(in: size)
                        } else if data.count == 1 {
                            singlePointView(in: size)
                        }
                        
                        // Data Points
                        dataPoints(in: size)
                        
                        // Zero Line
                        if hasNegativeData {
                            zeroLine(in: size)
                        }
                    }
                }
                .padding(20)
            } else {
                emptyStateView
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 40))
                .foregroundStyle(.gray)
            Text("No Data Available")
                .font(.headline)
                .foregroundStyle(.gray)
            Text("Add some data points to see the graph")
                .font(.caption)
                .foregroundStyle(.gray.opacity(0.7))
        }
    }
    
    // MARK: - Styled Components
    
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: hasNegativeData ?
                [Color.red.opacity(0.05), Color.red.opacity(0.1)] :
                [Color.gray.opacity(0.1), Color.gray.opacity(0.2)]
            ),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var backgroundStroke: some View {
        RoundedRectangle(cornerRadius: 20)
            .stroke(
                hasNegativeData ? Color.red.opacity(0.3) : Color.clear,
                lineWidth: hasNegativeData ? 2 : 0
            )
    }
    
    private var shadowColor: Color {
        hasNegativeData ? .red.opacity(0.2) : .black.opacity(0.1)
    }
    
    private var shadowRadius: CGFloat {
        hasNegativeData ? 15 : 10
    }
    
    private var lineGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: hasNegativeData ?
                [.red, .orange, .yellow] :
                [.blue, .green, .mint]
            ),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var fillGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: hasNegativeData ?
                [Color.red.opacity(0.4), Color.orange.opacity(0.1)] :
                [Color.green.opacity(0.3), Color.blue.opacity(0.1)]
            ),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // MARK: - Graph Components
    
    private func gridLines(in size: CGSize) -> some View {
        ZStack {
            // Horizontal lines
            ForEach(0..<5, id: \.self) { index in
                let y = size.height * (CGFloat(index) / 4)
                linePath(from: CGPoint(x: 0, y: y), to: CGPoint(x: size.width, y: y))
                    .stroke(gridLineColor, lineWidth: 1)
            }
            
            // Vertical lines
            ForEach(0..<5, id: \.self) { index in
                let x = size.width * (CGFloat(index) / 4)
                linePath(from: CGPoint(x: x, y: 0), to: CGPoint(x: x, y: size.height))
                    .stroke(gridLineColor, lineWidth: 1)
            }
        }
    }
    
    private func shadedArea(in size: CGSize) -> some View {
        Path { path in
            createShadedPath(path: &path, in: size)
        }
        .fill(fillGradient)
        .mask(
            Rectangle()
                .frame(width: size.width * trimAmount)
        )
    }
    
    private func lineGraph(in size: CGSize) -> some View {
        Path { path in
            createLinePath(path: &path, in: size)
        }
        .trim(from: 0, to: trimAmount)
        .stroke(
            lineGradient,
            style: StrokeStyle(
                lineWidth: hasNegativeData ? 5 : 4,
                lineCap: .round,
                lineJoin: .round
            )
        )
        .shadow(
            color: hasNegativeData ? .red.opacity(0.4) : .green.opacity(0.3),
            radius: hasNegativeData ? 10 : 8,
            y: 2
        )
    }
    
    private func dataPoints(in size: CGSize) -> some View {
        ForEach(data.indices, id: \.self) { index in
            dataPoint(at: index, in: size)
        }
    }
    
    private func dataPoint(at index: Int, in size: CGSize) -> some View {
        let isNegative = data[index] < 0
        
        return Circle()
            .fill(isNegative ? Color.red : Color.white)
            .frame(width: isNegative ? 14 : 12, height: isNegative ? 14 : 12)
            .overlay(
                Circle()
                    .stroke(pointStrokeGradient, lineWidth: isNegative ? 4 : 3)
            )
            .shadow(
                color: (isNegative ? Color.red : Color.green).opacity(0.6),
                radius: isNegative ? 10 : 8,
                y: 3
            )
            .position(scaledPoint(at: index, in: size))
            .scaleEffect(trimAmount == 1.0 ? 1.0 : 0.1)
            .animation(
                .spring(response: 0.6, dampingFraction: 0.7)
                .delay(Double(index) * 0.1),
                value: trimAmount
            )
    }
    
    private func zeroLine(in size: CGSize) -> some View {
        let zeroY = scaledPointForValue(0, in: size).y
        
        return ZStack {
            linePath(from: CGPoint(x: 0, y: zeroY), to: CGPoint(x: size.width, y: zeroY))
                .stroke(
                    Color.gray.opacity(0.5),
                    style: StrokeStyle(lineWidth: 1, dash: [5, 5])
                )
            
            Text("0")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.gray)
                .padding(4)
                .background(Color.white.opacity(0.8))
                .cornerRadius(4)
                .position(x: 25, y: zeroY)
        }
    }
    
    private func singlePointView(in size: CGSize) -> some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(singlePointStrokeColor.opacity(0.2 - Double(index) * 0.06), lineWidth: 2)
                    .frame(width: 40 + CGFloat(index) * 20, height: 40 + CGFloat(index) * 20)
                    .position(scaledPoint(at: 0, in: size))
            }
        }
    }
    
    // MARK: - Helper Properties
    
    private var gridLineColor: Color {
        hasNegativeData ? Color.red.opacity(0.1) : Color.gray.opacity(0.2)
    }
    
    private var pointStrokeGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: hasNegativeData ?
                [.red, .orange] :
                [.blue, .green]
            ),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var singlePointStrokeColor: Color {
        hasNegativeData ? Color.red : Color.green
    }
    
    // MARK: - Helper Functions
    
    private func linePath(from: CGPoint, to: CGPoint) -> Path {
        Path { path in
            path.move(to: from)
            path.addLine(to: to)
        }
    }
    
    private func scaledPoint(at index: Int, in size: CGSize) -> CGPoint {
        guard !data.isEmpty else { return .zero }
        
        let x: CGFloat
        if data.count == 1 {
            x = size.width / 2
        } else {
            x = size.width * (CGFloat(index) / CGFloat(data.count - 1))
        }
        
        let normalizedY = 1.0 - ((data[index] - minDataValue) / dataRange)
        let y = size.height * normalizedY
        
        return CGPoint(x: x, y: y)
    }
    
    private func scaledPointForValue(_ value: Double, in size: CGSize) -> CGPoint {
        let normalizedY = 1.0 - ((value - minDataValue) / dataRange)
        let y = size.height * normalizedY
        return CGPoint(x: size.width / 2, y: y)
    }
    
    private func createLinePath(path: inout Path, in size: CGSize) {
        guard data.count > 1 else { return }
        
        path.move(to: scaledPoint(at: 0, in: size))
        for index in 1..<data.count {
            path.addLine(to: scaledPoint(at: index, in: size))
        }
    }
    
    private func createShadedPath(path: inout Path, in size: CGSize) {
        guard data.count > 1 else { return }
        
        path.move(to: scaledPoint(at: 0, in: size))
        for index in 1..<data.count {
            path.addLine(to: scaledPoint(at: index, in: size))
        }
        path.addLine(to: CGPoint(x: size.width, y: size.height))
        path.addLine(to: CGPoint(x: 0, y: size.height))
        path.closeSubpath()
    }
    
    // MARK: - Animation Functions
    
    private func animateOnAppear() {
        withAnimation(.easeOut(duration: 1.2)) {
            trimAmount = 1.0
        }
        
        if hasNegativeData {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                warningPulse = 1.02
            }
        }
    }
    
    private func animateOnDataChange() {
        trimAmount = 0.0
        warningPulse = 1.0
        
        withAnimation(.easeOut(duration: 1.2)) {
            trimAmount = 1.0
        }
        
        if hasNegativeData {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    warningPulse = 1.02
                }
            }
        }
    }
}


#Preview {
    GraphView(data: .constant([0.0]))
}
