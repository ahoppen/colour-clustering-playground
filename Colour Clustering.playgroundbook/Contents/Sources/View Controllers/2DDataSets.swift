//
//  2DDataSets.swift
//  Book_Sources
//
//  Created by Alex Hoppen on 21.03.19.
//

import UIKit

private let dataSet1: [CGPoint] = [
    CGPoint(x: 0.38874999999999993, y: 0.365),
    CGPoint(x: 0.46249999999999997, y: 0.3225),
    CGPoint(x: 0.54125, y: 0.31875),
    CGPoint(x: 0.56625, y: 0.37875000000000003),
    CGPoint(x: 0.57125, y: 0.46499999999999997),
    CGPoint(x: 0.595, y: 0.3862500000000001),
    CGPoint(x: 0.47875, y: 0.39250000000000007),
    CGPoint(x: 0.56, y: 0.45624999999999993),
    CGPoint(x: 0.6, y: 0.42374999999999996),
    CGPoint(x: 0.51, y: 0.4212500000000001),
    CGPoint(x: 0.20249999999999999, y: 0.8225),
    CGPoint(x: 0.22749999999999995, y: 0.84875),
    CGPoint(x: 0.3175, y: 0.84375),
    CGPoint(x: 0.25249999999999995, y: 0.80625),
    CGPoint(x: 0.35750000000000004, y: 0.7987500000000001),
    CGPoint(x: 0.285, y: 0.80375),
    CGPoint(x: 0.26499999999999996, y: 0.8625),
    CGPoint(x: 0.37500000000000006, y: 0.81125),
    CGPoint(x: 0.35750000000000004, y: 0.8175),
    CGPoint(x: 0.28125, y: 0.82375),
    CGPoint(x: 0.35875, y: 0.7725000000000001),
    CGPoint(x: 0.27375, y: 0.7025),
    CGPoint(x: 0.25875, y: 0.7425),
    CGPoint(x: 0.33, y: 0.835),
    CGPoint(x: 0.855, y: 0.7975),
    CGPoint(x: 0.8225, y: 0.8087500000000001),
    CGPoint(x: 0.82875, y: 0.7875),
    CGPoint(x: 0.8475, y: 0.6699999999999999),
    CGPoint(x: 0.80375, y: 0.71375),
    CGPoint(x: 0.7649999999999999, y: 0.83125),
    CGPoint(x: 0.8375, y: 0.7675000000000001),
    CGPoint(x: 0.865, y: 0.7112499999999999),
    CGPoint(x: 0.8949999999999999, y: 0.72),
    CGPoint(x: 0.7675, y: 0.7925),
    CGPoint(x: 0.825, y: 0.76875),
    CGPoint(x: 0.8625, y: 0.7350000000000001),
    CGPoint(x: 0.88, y: 0.74125),
    CGPoint(x: 0.7999999999999999, y: 0.69625),
    CGPoint(x: 0.88, y: 0.62125),
    CGPoint(x: 0.8562500000000001, y: 0.665),
    CGPoint(x: 0.76125, y: 0.78125),
    CGPoint(x: 0.8375, y: 0.7825),
    CGPoint(x: 0.8175, y: 0.14500000000000002),
    CGPoint(x: 0.83625, y: 0.17125),
    CGPoint(x: 0.7599999999999999, y: 0.21125000000000005),
    CGPoint(x: 0.81125, y: 0.1725),
    CGPoint(x: 0.8712500000000001, y: 0.14625),
    CGPoint(x: 0.7825, y: 0.07625000000000004),
    CGPoint(x: 0.7399999999999999, y: 0.12124999999999997),
    CGPoint(x: 0.7699999999999999, y: 0.18874999999999997),
    CGPoint(x: 0.83875, y: 0.18500000000000005),
    CGPoint(x: 0.7449999999999999, y: 0.1137499999999999),
    CGPoint(x: 0.6875, y: 0.16874999999999996),
    CGPoint(x: 0.80625, y: 0.16749999999999998),
    CGPoint(x: 0.8325, y: 0.13624999999999998),
    CGPoint(x: 0.78375, y: 0.13249999999999995),
    CGPoint(x: 0.8049999999999999, y: 0.10000000000000009),
    CGPoint(x: 0.8912499999999999, y: 0.0625),
    CGPoint(x: 0.90875, y: 0.125),
    CGPoint(x: 0.8625, y: 0.26874999999999993),
    CGPoint(x: 0.8475, y: 0.22625000000000006),
    CGPoint(x: 0.84375, y: 0.1725),
]

private let dataSet2: [CGPoint] = [
    CGPoint(x: 0.485, y: 0.385),
    CGPoint(x: 0.55125, y: 0.3225),
    CGPoint(x: 0.50375, y: 0.2699999999999999),
    CGPoint(x: 0.46249999999999997, y: 0.20125000000000004),
    CGPoint(x: 0.50875, y: 0.16000000000000003),
    CGPoint(x: 0.5225, y: 0.14874999999999994),
    CGPoint(x: 0.42999999999999994, y: 0.13249999999999995),
    CGPoint(x: 0.51375, y: 0.14374999999999993),
    CGPoint(x: 0.52, y: 0.15000000000000002),
    CGPoint(x: 0.50625, y: 0.29125),
    CGPoint(x: 0.5787499999999999, y: 0.23125000000000007),
    CGPoint(x: 0.43249999999999994, y: 0.16000000000000003),
    CGPoint(x: 0.49, y: 0.24375000000000002),
    CGPoint(x: 0.5675, y: 0.21000000000000008),
    CGPoint(x: 0.46499999999999997, y: 0.24375000000000002),
    CGPoint(x: 0.5675, y: 0.1875),
    CGPoint(x: 0.46125, y: 0.22875),
    CGPoint(x: 0.5425, y: 0.26375000000000004),
    CGPoint(x: 0.44249999999999995, y: 0.3275),
    CGPoint(x: 0.535, y: 0.23750000000000004),
    CGPoint(x: 0.61125, y: 0.19000000000000006),
    CGPoint(x: 0.5025, y: 0.5975000000000001),
    CGPoint(x: 0.5475, y: 0.5900000000000001),
    CGPoint(x: 0.5537500000000001, y: 0.55),
    CGPoint(x: 0.5725, y: 0.5387500000000001),
    CGPoint(x: 0.505, y: 0.57625),
    CGPoint(x: 0.5862499999999999, y: 0.555),
    CGPoint(x: 0.49625, y: 0.50125),
    CGPoint(x: 0.3949999999999999, y: 0.5225),
    CGPoint(x: 0.51875, y: 0.56375),
    CGPoint(x: 0.5475, y: 0.57125),
    CGPoint(x: 0.43749999999999994, y: 0.54),
    CGPoint(x: 0.5575, y: 0.545),
    CGPoint(x: 0.45499999999999996, y: 0.59125),
    CGPoint(x: 0.545, y: 0.5787500000000001),
    CGPoint(x: 0.6224999999999999, y: 0.5475000000000001),
    CGPoint(x: 0.5275, y: 0.45124999999999993),
    CGPoint(x: 0.4725, y: 0.5225),
    CGPoint(x: 0.5912499999999999, y: 0.5900000000000001),
    CGPoint(x: 0.60125, y: 0.53625),
    CGPoint(x: 0.67, y: 0.49124999999999996),
    CGPoint(x: 0.62, y: 0.44875),
    CGPoint(x: 0.5750000000000001, y: 0.50125),
    CGPoint(x: 0.61625, y: 0.52625),
    CGPoint(x: 0.8375, y: 0.85625),
    CGPoint(x: 0.89, y: 0.8087500000000001),
    CGPoint(x: 0.8099999999999999, y: 0.78125),
    CGPoint(x: 0.83625, y: 0.87125),
    CGPoint(x: 0.94375, y: 0.8275),
    CGPoint(x: 0.81125, y: 0.78),
    CGPoint(x: 0.9199999999999999, y: 0.76875),
    CGPoint(x: 0.85, y: 0.80375),
    CGPoint(x: 0.8662500000000001, y: 0.8325),
    CGPoint(x: 0.9175, y: 0.785),
    CGPoint(x: 0.8049999999999999, y: 0.84625),
    CGPoint(x: 0.9062499999999999, y: 0.8275),
    CGPoint(x: 0.90875, y: 0.7737499999999999),
    CGPoint(x: 0.81125, y: 0.7425),
    CGPoint(x: 0.90875, y: 0.7737499999999999),
    CGPoint(x: 0.97125, y: 0.7225),
    CGPoint(x: 0.85, y: 0.6825),
    CGPoint(x: 0.8612500000000001, y: 0.7625000000000001),
    CGPoint(x: 0.93375, y: 0.8625),
    CGPoint(x: 0.95, y: 0.8187500000000001),
    CGPoint(x: 0.16125, y: 0.8025),
    CGPoint(x: 0.19624999999999998, y: 0.7737499999999999),
    CGPoint(x: 0.28375, y: 0.72125),
    CGPoint(x: 0.225, y: 0.7125),
    CGPoint(x: 0.13624999999999998, y: 0.79375),
    CGPoint(x: 0.2925, y: 0.8425),
    CGPoint(x: 0.27875, y: 0.7675000000000001),
    CGPoint(x: 0.21625, y: 0.7575000000000001),
    CGPoint(x: 0.24874999999999997, y: 0.84125),
    CGPoint(x: 0.21875, y: 0.895),
    CGPoint(x: 0.205, y: 0.87125),
    CGPoint(x: 0.30499999999999994, y: 0.77625),
    CGPoint(x: 0.23249999999999996, y: 0.7250000000000001),
    CGPoint(x: 0.27375, y: 0.775),
    CGPoint(x: 0.15875, y: 0.84625),
    CGPoint(x: 0.13749999999999998, y: 0.7625000000000001),
    CGPoint(x: 0.24374999999999997, y: 0.6575),
    CGPoint(x: 0.15, y: 0.7175),
    CGPoint(x: 0.3275, y: 0.7025),
    CGPoint(x: 0.37375, y: 0.6399999999999999),
    CGPoint(x: 0.42374999999999996, y: 0.625),
]

private let dataSet3: [CGPoint] = [
    CGPoint(x: 0.06499999999999999, y: 0.68875),
    CGPoint(x: 0.06374999999999999, y: 0.6799999999999999),
    CGPoint(x: 0.10874999999999999, y: 0.7375),
    CGPoint(x: 0.13249999999999998, y: 0.75375),
    CGPoint(x: 0.20375, y: 0.7975),
    CGPoint(x: 0.19124999999999998, y: 0.785),
    CGPoint(x: 0.10374999999999998, y: 0.7112499999999999),
    CGPoint(x: 0.18749999999999997, y: 0.7887500000000001),
    CGPoint(x: 0.27999999999999997, y: 0.8475),
    CGPoint(x: 0.37500000000000006, y: 0.90125),
    CGPoint(x: 0.3425, y: 0.8775),
    CGPoint(x: 0.22749999999999995, y: 0.79),
    CGPoint(x: 0.19249999999999998, y: 0.7362500000000001),
    CGPoint(x: 0.145, y: 0.67875),
    CGPoint(x: 0.27625, y: 0.79625),
    CGPoint(x: 0.37000000000000005, y: 0.8525),
    CGPoint(x: 0.44249999999999995, y: 0.88875),
    CGPoint(x: 0.26249999999999996, y: 0.78125),
    CGPoint(x: 0.25375, y: 0.7925),
    CGPoint(x: 0.4049999999999999, y: 0.88875),
    CGPoint(x: 0.52375, y: 0.95375),
    CGPoint(x: 0.3949999999999999, y: 0.905),
    CGPoint(x: 0.23874999999999996, y: 0.79375),
    CGPoint(x: 0.15625, y: 0.71375),
    CGPoint(x: 0.13999999999999999, y: 0.6399999999999999),
    CGPoint(x: 0.2125, y: 0.71375),
    CGPoint(x: 0.325, y: 0.8362499999999999),
    CGPoint(x: 0.38250000000000006, y: 0.86875),
    CGPoint(x: 0.5175, y: 0.93125),
    CGPoint(x: 0.47, y: 0.91375),
    CGPoint(x: 0.31249999999999994, y: 0.8175),
    CGPoint(x: 0.18624999999999997, y: 0.6950000000000001),
    CGPoint(x: 0.09624999999999997, y: 0.6187499999999999),
    CGPoint(x: 0.12625, y: 0.6499999999999999),
    CGPoint(x: 0.26625, y: 0.765),
    CGPoint(x: 0.3325, y: 0.82625),
    CGPoint(x: 0.42374999999999996, y: 0.8775),
    CGPoint(x: 0.50375, y: 0.9125),
    CGPoint(x: 0.21, y: 0.37875000000000003),
    CGPoint(x: 0.29375, y: 0.4025000000000001),
    CGPoint(x: 0.3275, y: 0.3662500000000001),
    CGPoint(x: 0.26625, y: 0.29999999999999993),
    CGPoint(x: 0.18624999999999997, y: 0.29499999999999993),
    CGPoint(x: 0.19624999999999998, y: 0.35375),
    CGPoint(x: 0.29625, y: 0.35875),
    CGPoint(x: 0.24874999999999997, y: 0.28625),
    CGPoint(x: 0.18874999999999997, y: 0.3175),
    CGPoint(x: 0.26249999999999996, y: 0.36),
    CGPoint(x: 0.33875, y: 0.3325),
    CGPoint(x: 0.24249999999999997, y: 0.25750000000000006),
    CGPoint(x: 0.20249999999999999, y: 0.2512500000000001),
    CGPoint(x: 0.26125, y: 0.21125000000000005),
    CGPoint(x: 0.34875, y: 0.2975),
    CGPoint(x: 0.28375, y: 0.2849999999999999),
    CGPoint(x: 0.2225, y: 0.35625000000000007),
    CGPoint(x: 0.44749999999999995, y: 0.645),
    CGPoint(x: 0.485, y: 0.6287499999999999),
    CGPoint(x: 0.5425, y: 0.6224999999999999),
    CGPoint(x: 0.5974999999999999, y: 0.6075000000000002),
    CGPoint(x: 0.6124999999999999, y: 0.5675000000000001),
    CGPoint(x: 0.69125, y: 0.5325),
    CGPoint(x: 0.70375, y: 0.49875),
    CGPoint(x: 0.58, y: 0.52875),
    CGPoint(x: 0.50125, y: 0.5787500000000001),
    CGPoint(x: 0.53625, y: 0.57375),
    CGPoint(x: 0.635, y: 0.45624999999999993),
    CGPoint(x: 0.6875, y: 0.45375),
    CGPoint(x: 0.7225, y: 0.4312499999999999),
    CGPoint(x: 0.7437499999999999, y: 0.39375000000000004),
    CGPoint(x: 0.68375, y: 0.3975000000000001),
    CGPoint(x: 0.6237499999999999, y: 0.45375),
    CGPoint(x: 0.5475, y: 0.5675000000000001),
    CGPoint(x: 0.5725, y: 0.5850000000000001),
    CGPoint(x: 0.6487499999999999, y: 0.56375),
    CGPoint(x: 0.71625, y: 0.475),
    CGPoint(x: 0.7437499999999999, y: 0.42999999999999994),
    CGPoint(x: 0.7699999999999999, y: 0.43875),
    CGPoint(x: 0.65, y: 0.49624999999999997),
    CGPoint(x: 0.7275, y: 0.40375000000000005),
    CGPoint(x: 0.5475, y: 0.5887500000000001),
    CGPoint(x: 0.6087499999999999, y: 0.5425),
    CGPoint(x: 0.64, y: 0.48875),
    CGPoint(x: 0.80125, y: 0.8362499999999999),
    CGPoint(x: 0.83625, y: 0.13624999999999998),
]

let dataSets = [
    dataSet1,
    dataSet2,
    dataSet3
]
