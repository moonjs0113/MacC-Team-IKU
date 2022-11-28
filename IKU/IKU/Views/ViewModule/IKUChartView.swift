//
//  IKUChartView.swift
//  IKU
//
//  Created by Moon Jongseek on 2022/11/11.
//

import SwiftUI
import Charts

class IKUChartView: UIView {
    // MARK: - Properties
    
    // MARK: - Methods
    func setupView() {
        guard let ikuChart = UIHostingController(rootView: IKUChart()).view else {
            return
        }
        ikuChart.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(ikuChart)
        NSLayoutConstraint.activate([
            ikuChart.widthAnchor.constraint(equalTo: widthAnchor),
            ikuChart.heightAnchor.constraint(equalTo: heightAnchor),
            ikuChart.centerXAnchor.constraint(equalTo: centerXAnchor),
            ikuChart.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    // MARK: - IBOutlets
    
    // MARK: - IBActions
    
    // MARK: - Delegates And DataSources
    
    // MARK: - Life Cycles
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct IKUChart: View {
    var body: some View {
        Group {
            VStack {
                HStack(spacing: 2) {
//                    Image(systemName: "eye")
                    Text("Graph Chart")
                        .font(Font(UIFont.nexonGothicFont(ofSize: 17, weight: .bold)))
                    Spacer()
                }
                .padding([.leading, .top, .trailing])
                .foregroundColor(Color(uiColor: .ikuBlue))
                
                ZStack {
                    Chart {
                        ForEach(StrabismusLog.previews, id: \.self) {
                            LineMark  (
                                x: .value("", $0.date),
                                y: .value("Strabismus Angle", $0.degree)
                            )
                            .lineStyle(.init(lineWidth: 1))
                            .foregroundStyle(Color(uiColor: .ikuBlue))
                            
                            AreaMark (
                                x: .value("", $0.date),
                                y: .value("Strabismus Angle", $0.degree)
                            )
                            .foregroundStyle(
                                Gradient(colors: [
                                    Color(uiColor: .ikuBlue),
                                    Color(uiColor: .ikuBlue).opacity(0.2)
                                ]).opacity(0.3)
                            )
                            .interpolationMethod(.linear)
                        }
                    }
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                    
                    Text("Please check cross-eyed record")
                        .font(Font(UIFont.nexonGothicFont(ofSize: 17, weight: .light)))
                        .foregroundColor(Color(uiColor: .ikuCalendarWeeklyTitle))
                }
            }
        }
    }
}

struct IKUChart_Previews: PreviewProvider {
    static var previews: some View {
        IKUChart()
    }
}
