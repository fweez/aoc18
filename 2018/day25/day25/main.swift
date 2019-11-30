//
//  main.swift
//  day25
//
//  Created by Ryan Forsythe on 12/31/18.
//  Copyright © 2018 Zero Gravitas. All rights reserved.
//

import Foundation

enum ParseError: Error {
    case BadInput(String)
}

struct SpacetimePoint {
    var x: Int
    var y: Int
    var z: Int
    var t: Int
    
    init(input: String) throws {
        let split = input.split(separator: ",")
        let ints = try split.map( { (s: Substring) throws -> Int in
            let s = String(s)
            guard let i = Int(s) else { throw ParseError.BadInput(s) }
            return i
        })
        guard ints.count == 4 else { throw ParseError.BadInput(input) }
        self.x = ints[0]
        self.y = ints[1]
        self.z = ints[2]
        self.t = ints[3]
    }
    
    func distance(other: SpacetimePoint) -> Int {
        let dx = abs(self.x - other.x)
        let dy = abs(self.y - other.y)
        let dz = abs(self.z - other.z)
        let dt = abs(self.t - other.t)
        return dx + dy + dz + dt
    }
}

extension SpacetimePoint: Equatable { }
extension SpacetimePoint: Hashable { }
extension SpacetimePoint: CustomStringConvertible {
    var description: String {
        return "(\(self.x), \(self.y), \(self.z), \(self.t))"
    }
}

class Constellation {
    var points: Set<SpacetimePoint> = Set()
    
    init(points: Set<SpacetimePoint>) {
        self.points = points
    }
    
    func join(other: Constellation) {
        for myp in self.points {
            for otherp in other.points {
                if myp.distance(other: otherp) <= 3 {
                    //print("Joining because distance between \(myp) and \(otherp) is <= 3")
                    self.points.formUnion(other.points)
                    other.points = Set()
                    return
                }
            }
        }
    }
}

extension Constellation: Equatable {
    static func == (lhs: Constellation, rhs: Constellation) -> Bool {
        return lhs.points == rhs.points
    }
}

extension Constellation: Hashable {
    func hash(into hasher: inout Hasher) {
        for point in self.points {
            hasher.combine(point)
        }
    }
}

extension Constellation: CustomStringConvertible {
    var description: String {
        return "Constellation of \(self.points.count) points: \(self.points)"
    }
}

struct Sky {
    var constellations: Set<Constellation>
    
    init(input: String) throws {
        self.constellations = Set(try input.split(separator: "\n").map { (s) throws -> Constellation in
            let point = try SpacetimePoint(input: String(s))
            return Constellation(points: Set([point]))
        })
        var count = Int.max
        while self.constellations.count != count {
            count = self.constellations.count
            
            for a in self.constellations {
                for b in self.constellations {
                    if a == b { continue }
                    a.join(other: b)
                }
            }
            
            self.constellations = self.constellations.filter({ $0.points.isEmpty == false })
        }
    }
}

let testing = false

if testing {
    func test(input: String, expected: Int) {
        do {
            let s = try Sky(input: input)
            assert(s.constellations.count == expected)
        } catch {
            assertionFailure()
        }
    }
    test(input: """
    0,0,0,0
    3,0,0,0
    0,3,0,0
    0,0,3,0
    0,0,0,3
    0,0,0,6
    9,0,0,0
    12,0,0,0
    """, expected: 2)
    test(input: """
    -1,2,2,0
    0,0,2,-2
    0,0,0,-2
    -1,2,0,0
    -2,-2,-2,2
    3,0,2,-1
    -1,3,2,2
    -1,0,-1,0
    0,2,1,-2
    3,0,0,0
    """, expected: 4)
    test(input: """
    1,-1,0,1
    2,0,-1,0
    3,2,-1,0
    0,0,3,1
    0,0,-1,-1
    2,3,-2,0
    -2,2,0,0
    2,-2,0,-1
    1,-1,0,-1
    3,2,0,2
    """, expected: 3)
    test(input: """
    1,-1,-1,-2
    -2,-2,0,1
    0,2,1,3
    -2,3,-2,1
    0,2,3,-2
    -1,-1,1,-2
    0,-2,-1,0
    -2,2,3,-1
    1,2,2,0
    -1,-2,0,-2
    """, expected: 8)
} else {
    func run(_ input: String) {
        do {
            let s = try Sky(input: input)
            print("Costellations formed: \(s.constellations.count)")
        } catch {
            assertionFailure()
        }
    }
    run("""
    -7,-3,-4,-6
    -7,1,1,1
    -6,1,-4,-7
    -1,-3,7,0
    5,5,-1,0
    -3,-3,-1,8
    -6,-3,-1,0
    7,8,0,-7
    -5,-5,-8,0
    2,3,-2,7
    3,-2,5,-6
    6,-3,2,-1
    4,2,1,-4
    8,-8,-5,1
    0,5,-1,-4
    7,-4,-3,7
    -8,0,8,5
    -2,-6,-8,7
    -8,-1,1,5
    2,-2,3,-3
    6,0,-8,1
    1,5,1,3
    3,-6,-4,5
    0,2,0,0
    -3,-1,-6,5
    2,-3,1,-5
    -8,1,-5,0
    -6,-7,1,3
    3,1,-8,2
    1,5,-1,-8
    5,3,8,-2
    0,5,-5,5
    -8,3,-7,-5
    -2,-7,-3,-4
    -1,-1,4,-1
    0,-1,-3,2
    4,-2,-7,-8
    -7,4,-7,3
    -5,-5,7,8
    -3,-6,-5,1
    -4,1,6,0
    -6,1,0,8
    8,1,-3,0
    2,0,3,7
    6,5,1,-5
    -3,-1,6,5
    3,-4,4,-7
    -3,-5,-8,-6
    -3,2,-4,-6
    1,-5,0,2
    1,-4,-7,4
    5,3,8,-7
    -5,0,-6,8
    5,5,-8,-3
    -8,-7,-5,-2
    3,-7,6,-5
    -6,-6,6,1
    -7,4,8,3
    -6,-7,-7,7
    -1,-5,-1,2
    -8,-1,-1,-2
    6,-7,1,2
    5,1,-5,8
    6,3,3,4
    4,6,2,8
    0,2,-4,7
    -4,-7,0,8
    1,-3,-3,-6
    2,7,-6,7
    -2,-4,-1,5
    -6,8,1,7
    -5,-2,3,-7
    0,0,3,-1
    -7,2,-3,0
    -6,5,6,1
    -5,-7,-1,6
    -6,-8,0,7
    -5,8,1,-5
    2,7,6,-3
    3,4,7,-3
    -8,0,-3,7
    2,1,6,0
    -4,0,0,3
    -4,8,-7,-6
    0,2,8,7
    -4,2,-4,0
    5,6,1,-3
    -8,7,-4,5
    -8,8,-1,-8
    6,-8,0,0
    4,4,-3,2
    0,-7,-6,4
    2,8,6,6
    -2,-3,0,7
    -2,6,-6,8
    -6,0,-8,2
    8,-5,6,-2
    8,3,-1,7
    -3,7,-1,4
    -3,-8,-1,7
    -4,8,7,-5
    -2,-6,8,-1
    0,-7,-8,-2
    -2,0,-6,8
    0,2,-5,-6
    -1,4,-6,-6
    -2,-4,-6,0
    -3,-6,-1,8
    -6,0,1,5
    3,-2,3,-2
    8,-3,-2,8
    -3,6,0,3
    -6,6,-1,-5
    2,-8,5,-4
    -4,1,-5,4
    2,8,-7,-6
    -3,-1,6,-3
    4,-6,-8,-1
    5,-6,5,-5
    -4,4,-7,3
    -7,1,-2,-2
    0,-5,-3,-7
    -8,4,5,-6
    -7,8,3,0
    6,-4,0,-3
    -6,3,0,-1
    -3,4,-5,-6
    6,1,-3,4
    -1,-1,-2,7
    -6,-2,-5,4
    -6,5,-3,8
    -7,3,-3,3
    5,7,-6,6
    1,-3,-8,6
    -2,2,-8,0
    2,5,-8,0
    2,-5,2,4
    7,-5,0,1
    5,3,0,5
    2,0,-6,8
    5,8,-6,5
    4,7,6,-2
    5,-4,-7,7
    -3,-4,-8,3
    -2,8,8,1
    6,-3,0,-7
    -8,3,4,6
    8,1,0,0
    3,-8,-4,-3
    1,6,0,-5
    7,3,3,-5
    5,1,3,-8
    -1,-6,0,0
    2,7,8,-5
    2,1,-1,5
    1,7,-4,0
    8,1,-4,0
    8,-3,-7,1
    -4,-5,-7,5
    -6,-5,1,2
    -2,4,8,-7
    0,-6,-5,0
    4,0,-1,-5
    -5,-3,0,-4
    -6,6,-7,-3
    -4,5,8,1
    1,0,4,-8
    0,6,-7,2
    7,5,8,2
    4,-3,-6,6
    -4,-4,-6,5
    -7,5,2,0
    6,-1,4,5
    -1,-7,8,4
    2,-3,-6,0
    -8,-2,7,6
    -8,-1,-4,6
    6,4,5,1
    8,3,6,-6
    0,-3,-7,2
    -6,2,-2,2
    6,6,6,0
    7,5,-5,4
    -4,-2,3,1
    -2,-4,3,2
    0,-2,0,3
    -2,0,0,5
    -4,3,6,2
    -5,4,3,0
    -3,3,5,0
    1,-1,8,1
    -8,5,-3,8
    0,8,-7,1
    -3,2,3,0
    0,0,-8,7
    -8,-3,-6,8
    -2,8,-2,0
    -3,-3,8,-6
    -5,-2,1,0
    7,-8,0,-8
    3,4,7,0
    0,-7,-5,3
    -6,8,1,-6
    8,-3,8,4
    6,-1,-3,8
    -5,-2,0,-6
    4,3,-8,3
    -1,4,-2,-8
    4,3,-1,-3
    4,-3,-6,0
    -8,5,-1,-4
    3,8,-6,1
    -4,-2,1,5
    1,-5,0,-1
    -4,-8,3,-8
    0,4,1,4
    2,-2,-4,1
    8,1,4,-4
    6,-2,-8,-8
    -1,-6,2,-8
    -4,-7,-7,4
    7,6,0,-2
    5,6,-7,-2
    1,-8,7,0
    3,2,1,5
    -3,-8,-8,-3
    5,-1,1,5
    0,-4,7,-8
    1,2,-6,4
    8,7,-1,8
    -4,-5,-1,6
    8,-6,3,3
    -1,-6,-8,3
    6,8,-8,-5
    -8,0,-2,8
    -1,8,1,5
    4,-5,6,-4
    0,4,5,0
    -4,-2,0,4
    -5,-8,4,7
    -6,-8,6,-6
    2,3,5,8
    5,5,1,5
    4,-2,-4,-8
    4,5,-6,5
    -4,3,-7,0
    7,4,7,-6
    7,3,-5,-2
    -7,6,3,-6
    3,-1,2,2
    -1,-5,8,6
    4,-8,4,-6
    -1,5,1,5
    3,0,2,0
    5,0,-2,-7
    0,-6,-1,-8
    7,-4,6,0
    -1,7,-4,-1
    -8,-4,8,-3
    -4,1,-3,-7
    6,-1,-5,6
    -8,4,-2,-2
    4,-7,-3,6
    6,-7,0,-2
    1,-8,1,-6
    -1,-1,-4,4
    3,6,4,2
    2,5,-4,-6
    7,7,6,4
    1,-1,-4,6
    6,0,7,1
    -5,-5,-6,-4
    5,3,5,8
    6,0,1,8
    -7,-1,5,8
    -2,7,3,-6
    6,4,0,-1
    5,0,2,0
    -8,-6,-8,2
    8,8,-4,3
    -6,8,4,1
    5,-8,-4,-4
    7,6,6,-3
    3,4,0,8
    7,-8,-7,-1
    0,-8,0,-5
    -3,7,5,5
    -7,7,5,-6
    7,-1,8,0
    7,8,4,5
    -7,-6,-5,8
    6,-5,1,-2
    5,0,4,0
    5,4,-4,-1
    -3,-1,8,-4
    -1,2,-5,6
    -2,0,2,-7
    -6,-2,-8,-5
    4,3,4,5
    -7,8,-4,4
    1,5,7,-5
    -6,0,-6,-7
    0,-2,5,7
    0,-1,-6,0
    -8,-6,4,-8
    -6,0,-4,0
    3,-4,4,0
    7,-3,8,1
    0,2,8,-1
    -4,5,-3,1
    6,-3,0,8
    -3,-6,8,-2
    -7,-1,3,-8
    7,2,6,-3
    -1,2,-4,1
    3,6,-4,8
    -6,8,-1,-3
    7,6,8,7
    4,-2,-5,0
    2,8,1,-5
    5,7,0,-5
    1,-3,1,5
    0,7,2,5
    -6,7,0,0
    -2,2,3,6
    5,-6,-2,7
    6,-2,-2,0
    -2,7,0,-1
    -2,-4,-6,-7
    7,-3,2,-3
    -2,0,-4,-8
    7,2,7,8
    -8,-7,-6,-4
    0,1,0,-6
    -1,0,-3,-7
    -8,7,7,6
    -1,-6,-6,4
    -7,1,8,1
    -1,-8,1,0
    3,-6,-2,-2
    3,3,-4,-3
    1,2,6,6
    -2,0,0,4
    6,8,0,-7
    -1,8,8,5
    0,7,2,0
    8,-7,-3,0
    -2,2,2,7
    -6,-6,-6,-6
    7,-1,1,2
    -7,-8,0,7
    4,5,0,-4
    -5,8,1,5
    -3,1,-6,-6
    6,-8,-6,4
    3,1,-6,-5
    4,-1,1,5
    5,-6,-3,-6
    4,2,-8,4
    -1,-5,4,-1
    0,8,7,6
    -2,1,-5,8
    -4,8,6,-6
    -7,6,0,0
    -7,-1,-8,6
    2,0,4,2
    0,-7,8,-8
    -1,-5,-3,-4
    7,6,2,-5
    -7,-4,-4,6
    0,4,2,0
    -6,3,0,3
    2,6,-8,0
    -3,-5,-6,0
    -5,-2,0,-2
    0,-7,0,6
    8,-6,0,7
    -8,-6,-4,-3
    0,0,-5,2
    6,-8,-3,3
    -2,-1,6,-2
    5,1,7,0
    2,-4,-3,4
    2,-7,6,-8
    5,-2,-6,0
    6,-2,1,4
    7,4,4,8
    4,-3,5,4
    -7,-2,2,-2
    -7,4,1,7
    -8,7,8,5
    3,0,2,-4
    4,-3,5,-4
    -1,-5,5,-4
    -4,1,-4,0
    5,4,-6,-8
    8,-8,0,6
    8,7,6,-8
    0,7,7,8
    2,-8,4,-5
    0,-4,-6,-5
    -5,-5,7,4
    4,5,4,-3
    -4,-1,6,-7
    0,-5,-5,6
    4,4,3,3
    -3,3,0,-5
    7,5,4,0
    -3,-8,1,-1
    0,-4,-1,-3
    0,3,-8,-5
    -5,-8,-1,0
    4,-4,8,-3
    8,0,-8,5
    2,0,6,-5
    -4,0,-7,2
    -5,2,3,3
    4,4,0,3
    -8,0,8,0
    5,-3,-6,-4
    -2,-8,1,-4
    7,-4,-7,-1
    3,4,6,-6
    -7,-5,-3,-3
    8,0,0,-4
    2,0,0,4
    -5,-3,7,5
    2,3,-8,1
    -8,3,4,-5
    -6,8,-3,-5
    0,0,5,6
    -7,-7,-2,-1
    2,7,2,-6
    4,-6,-7,-4
    8,-5,-4,7
    5,3,-5,7
    6,8,7,8
    -6,-3,-4,0
    5,-4,-7,-8
    -1,0,-1,8
    7,0,-6,6
    1,8,-5,2
    5,-1,4,7
    -1,0,-7,1
    -4,6,-8,3
    0,-7,8,8
    -4,6,3,-7
    6,0,-1,3
    1,-7,1,-5
    -7,-3,-3,-5
    -3,1,6,-1
    3,0,-3,8
    6,-1,-5,-7
    2,7,4,-5
    -3,8,4,-3
    -4,6,6,6
    2,1,1,-1
    -3,4,-2,-6
    2,0,-2,8
    -8,0,-1,-8
    4,8,4,0
    3,8,-2,4
    6,0,6,1
    -8,-1,-8,-4
    5,-1,-1,-7
    -5,0,-1,7
    -8,3,4,-3
    0,-1,-4,2
    5,3,0,0
    -8,-6,-5,-1
    5,-3,0,4
    1,4,7,7
    3,2,0,1
    3,-2,5,0
    0,0,-3,8
    -8,7,7,7
    0,-5,0,-7
    -1,2,0,-2
    -2,2,-6,5
    7,4,-4,-8
    3,-7,5,6
    -8,-3,7,-2
    -7,7,5,-3
    -8,-4,3,-7
    -2,3,4,7
    -6,2,7,7
    2,5,-2,1
    -5,2,2,-8
    1,6,7,1
    4,5,0,2
    5,-5,8,6
    -3,-2,0,-5
    -4,0,4,-1
    8,-7,0,2
    -7,0,7,-2
    3,-5,-3,-5
    0,0,-8,-4
    -8,8,5,3
    0,7,0,1
    3,5,-5,2
    3,0,0,-7
    0,-1,-4,-7
    -8,-7,1,-3
    -8,-1,-5,3
    6,-2,-2,-2
    4,-4,7,-1
    1,6,2,6
    -6,0,4,0
    -5,-1,3,-6
    1,4,0,-4
    -8,-8,-5,6
    4,6,4,5
    0,-4,-5,-8
    8,6,-7,-7
    6,4,4,2
    -3,7,-2,0
    3,4,-2,1
    5,3,8,-3
    1,6,-6,-7
    0,-6,5,1
    6,6,-7,7
    6,4,-3,-7
    -6,-7,-4,4
    -6,0,3,2
    -5,5,2,6
    5,7,-3,-7
    -3,-1,-1,0
    1,0,2,6
    1,-7,-2,0
    -4,7,8,4
    1,0,-6,1
    7,6,-5,-8
    5,-8,8,7
    0,-7,6,-4
    4,8,3,-2
    0,1,-1,0
    5,-7,-3,-1
    8,-5,0,6
    3,5,4,-5
    5,4,5,-6
    8,4,-3,-3
    2,3,-1,1
    4,-7,-4,-1
    1,-5,-2,-4
    8,-1,-1,2
    -8,-6,-6,-5
    -7,6,-4,-1
    -2,2,3,8
    0,-3,-7,-6
    -5,-4,5,-4
    8,-1,-6,0
    -1,8,-6,6
    -1,-4,-8,1
    7,3,7,5
    -5,6,2,0
    5,1,-3,3
    0,7,7,1
    0,-6,4,2
    -4,3,1,-4
    -8,2,-7,-7
    1,1,1,2
    -1,1,2,3
    2,-3,-7,-7
    7,-6,6,0
    -7,7,-6,6
    -3,-3,6,-1
    0,0,-7,5
    -4,-3,0,7
    1,1,-5,-3
    0,8,7,-5
    7,-5,3,-8
    -4,-4,1,-5
    7,7,7,6
    3,-3,-8,-4
    6,5,3,1
    5,-5,-2,0
    6,-8,7,7
    -8,-1,-2,-6
    6,-7,-3,-5
    0,6,3,6
    -6,3,3,-3
    -6,-7,0,0
    -4,1,-7,-7
    -3,0,-4,3
    -7,-1,1,6
    -2,-4,8,1
    0,-4,5,-8
    -2,4,-7,-3
    -2,-5,2,4
    -7,-4,2,8
    -5,-3,-5,5
    8,-3,5,0
    6,7,-4,8
    -2,-3,0,-7
    -6,3,-7,-2
    1,-1,6,2
    -6,0,1,2
    -3,-5,4,-2
    8,2,0,7
    -8,-6,-3,8
    8,-3,2,6
    0,-6,5,4
    6,0,1,-6
    -4,5,-4,1
    -5,8,-2,2
    7,0,5,-1
    -1,0,0,2
    1,-1,-2,8
    0,-7,-7,4
    -7,-3,1,8
    4,6,1,4
    7,8,5,-7
    -2,1,7,4
    7,-2,2,0
    -1,-2,-2,0
    7,-3,-5,0
    -7,0,6,8
    3,-5,-8,0
    -5,-5,-1,5
    -6,7,3,-8
    2,0,0,6
    7,-4,-2,5
    -3,8,7,-5
    5,4,1,6
    -4,4,-4,-1
    -8,-1,0,1
    0,-3,2,1
    -6,-4,-2,-5
    6,1,-1,-7
    3,-1,2,-7
    0,4,1,7
    5,4,6,-4
    -3,0,8,-7
    0,-8,1,2
    8,5,2,0
    -1,8,-8,6
    0,4,-1,-5
    5,6,-1,8
    -6,0,-4,6
    1,6,8,0
    3,-2,-5,7
    2,6,5,-6
    1,8,-1,-1
    6,-5,-6,-8
    -6,2,-3,2
    3,-8,7,3
    1,-8,-3,-8
    1,-7,-5,3
    -8,-5,-7,8
    -8,-2,-7,4
    5,-8,-4,-3
    3,3,-3,2
    -8,3,7,3
    3,-6,-2,5
    5,-3,-7,-8
    -5,3,-4,0
    5,3,-8,-5
    7,1,-1,6
    4,1,6,-5
    2,4,3,0
    -3,6,-8,2
    4,-8,-2,6
    -5,-7,4,-2
    4,2,-5,-2
    7,-7,-6,8
    3,8,3,0
    2,0,-3,5
    -3,5,-7,4
    -4,5,-3,0
    -3,0,-2,-5
    8,-8,2,0
    7,6,-8,6
    -4,4,-1,1
    7,6,0,1
    -2,-2,4,1
    7,8,-2,-2
    -1,7,0,7
    5,4,7,6
    7,8,7,5
    1,-5,6,-4
    1,0,2,4
    -5,8,-7,5
    -5,2,-2,-5
    0,6,7,0
    0,-6,7,-3
    4,4,2,0
    2,8,6,4
    1,-8,0,1
    3,-5,-3,-4
    0,8,0,-4
    -2,6,0,-5
    -5,-6,6,-4
    -4,5,-1,7
    7,6,-3,-7
    0,2,-6,0
    0,7,-6,-3
    -5,-1,4,0
    -6,-2,0,4
    6,7,-5,2
    7,-5,2,-1
    -7,5,-3,6
    -4,2,0,1
    8,1,6,0
    4,3,0,2
    7,-5,-8,7
    -7,3,-2,1
    3,-2,-6,7
    0,3,5,-5
    7,-7,-8,5
    8,-3,-6,0
    -2,-8,-8,-1
    -1,-5,-8,-6
    -3,0,-4,4
    -6,1,0,-6
    -4,3,7,7
    8,-7,-5,-8
    -2,1,-2,3
    -1,-4,-6,-6
    -5,8,-5,-8
    -1,-5,8,5
    4,-6,0,-2
    -5,-1,1,-7
    7,-3,-6,4
    -6,0,6,-4
    -4,-4,7,6
    -4,-1,4,8
    -7,-1,3,3
    3,3,-8,-8
    -4,7,-5,2
    -6,7,0,-6
    8,0,-7,-6
    5,-8,4,-4
    6,-2,-8,8
    0,-7,-2,8
    -7,4,-7,5
    -7,-8,2,4
    -3,4,-6,-6
    1,7,3,0
    6,8,-7,6
    4,0,-1,1
    8,-2,-2,-6
    0,0,8,2
    -1,3,-3,0
    -8,3,-8,-4
    -1,-2,3,-7
    -7,0,8,-7
    1,0,-3,-8
    1,2,6,7
    7,6,5,-7
    -2,6,2,5
    -6,0,-8,-2
    1,-5,-1,-1
    1,3,-2,5
    -8,-3,-2,-5
    -7,-2,8,0
    -1,-2,0,0
    -2,6,0,-3
    0,-1,0,6
    0,0,-1,7
    8,7,8,0
    7,-4,4,7
    0,4,-3,5
    2,0,-8,-6
    0,-1,7,2
    -4,0,-4,4
    1,-6,-5,-4
    6,5,-1,2
    6,7,7,3
    -2,-6,-8,-5
    -1,8,-8,7
    2,4,1,-7
    -5,2,-8,5
    -5,5,-6,6
    5,1,-7,-1
    -8,-6,-2,1
    -5,-8,-2,2
    1,-8,-2,-2
    6,0,1,7
    -2,0,-3,2
    1,-8,-6,5
    -6,-7,2,-3
    1,2,7,-8
    -5,-3,-8,-6
    -1,6,1,-6
    -8,-2,-2,4
    2,-5,-4,-8
    -3,4,-8,-8
    6,-3,5,7
    5,-4,2,-2
    0,-2,0,4
    -5,1,-8,8
    -1,-7,0,3
    -6,7,-3,4
    3,3,-1,-2
    -3,-1,-2,7
    1,1,-2,8
    2,3,-5,-7
    -3,-5,5,-1
    -2,-3,5,-8
    -5,-5,-4,-3
    -3,0,7,7
    -1,4,2,0
    6,-4,2,4
    6,2,6,-5
    -2,1,-8,-2
    0,-6,8,0
    1,1,-3,-7
    1,6,2,-2
    -3,4,2,1
    -4,-1,6,5
    7,0,-1,-1
    4,-7,-7,-3
    -6,6,-1,6
    7,-8,7,-1
    -8,-8,-7,7
    -5,1,-3,0
    2,1,-6,0
    0,0,-6,-7
    0,5,0,1
    3,8,0,5
    5,-2,-8,-1
    8,0,-3,-8
    6,2,-5,-4
    -8,7,4,7
    -2,-7,2,-1
    -1,3,4,-6
    -4,-3,2,4
    4,8,-3,-8
    2,-4,3,-3
    6,-8,-7,-4
    4,-4,1,3
    0,6,-4,5
    1,-2,-7,1
    -4,-8,7,-4
    -1,-3,-3,5
    -7,6,5,5
    0,-1,-4,0
    6,4,4,0
    -2,7,-4,-6
    -2,-5,0,1
    -2,8,7,3
    7,-6,-3,8
    5,7,3,-4
    3,-6,-5,0
    -8,8,8,5
    -1,7,-4,-7
    8,0,7,-8
    -7,0,7,-5
    5,-2,-7,-7
    -6,-1,7,-5
    1,4,2,-4
    -6,6,1,0
    -5,5,1,-5
    -8,5,5,-6
    7,6,6,0
    2,-6,4,-8
    0,-1,7,5
    2,1,-5,3
    0,7,-1,-8
    4,-7,0,-1
    6,3,-4,2
    2,-6,-6,-5
    7,2,0,-5
    8,-8,1,8
    -6,2,3,3
    -1,6,-8,-7
    5,6,-6,2
    2,-7,-4,6
    8,0,2,-5
    2,-1,7,3
    -5,-7,-4,8
    0,-7,-6,-5
    0,0,2,0
    -8,-8,-4,-5
    3,-2,-4,1
    8,0,7,-7
    2,-8,6,0
    -2,-3,2,-4
    6,0,8,4
    -1,-8,-2,3
    3,0,1,-5
    0,-7,6,-8
    -2,-8,8,-1
    4,-6,-1,2
    3,5,-1,-8
    2,-8,-3,-2
    3,1,0,1
    3,1,7,3
    -1,-8,-4,-2
    -4,-2,8,8
    -7,2,2,4
    3,4,-5,-6
    2,8,-3,8
    3,-1,6,4
    -5,3,6,-5
    3,7,0,8
    -4,-8,-8,6
    -3,5,0,5
    -4,0,-1,-4
    8,-4,0,1
    4,-3,-5,-2
    3,-6,2,-5
    2,-3,5,-1
    -5,5,-3,8
    5,8,0,3
    6,-6,5,6
    4,2,7,0
    2,-1,-6,3
    -8,0,8,-7
    -1,3,4,7
    -2,3,-2,2
    -1,1,0,2
    -2,-8,-3,3
    7,7,0,2
    7,-2,4,-1
    -2,1,7,0
    0,-8,3,-4
    -8,-1,0,-1
    1,0,3,7
    -4,-3,6,-4
    2,3,-6,5
    -1,2,8,-8
    -3,-3,-4,0
    -2,3,7,0
    0,-5,6,0
    3,-2,-7,-6
    0,0,6,-6
    2,1,7,8
    6,-8,3,5
    -3,-1,0,-7
    0,5,1,8
    8,7,6,-3
    -3,6,4,4
    -3,-5,-2,-5
    0,5,-7,4
    8,6,-6,-3
    0,-1,0,-3
    -3,-2,-1,6
    -7,-6,7,0
    -1,-4,4,1
    -3,3,4,0
    -4,6,-4,-7
    5,8,-1,7
    1,2,8,-2
    -4,-8,0,1
    -1,-2,8,-5
    1,7,-8,7
    -6,1,6,0
    -7,-3,0,2
    7,-1,-8,6
    8,-4,7,1
    4,4,8,6
    4,-2,-7,3
    -5,-2,-3,-1
    -7,-5,5,-3
    -3,8,7,2
    8,3,-2,6
    0,-3,5,0
    -6,6,-5,-4
    -4,0,7,-6
    -6,6,0,5
    4,-8,0,-5
    -4,4,-2,0
    4,-1,2,5
    1,0,3,3
    8,0,1,1
    0,-6,-4,5
    -5,3,0,1
    -1,-1,-8,-8
    -8,-3,-5,3
    -1,1,-1,-7
    1,4,-7,7
    -3,-7,7,-4
    -7,-1,3,7
    1,-6,-6,0
    0,-3,3,8
    -3,5,-5,-5
    -8,-2,3,8
    -7,-3,6,8
    0,3,5,6
    -4,3,-3,4
    0,6,5,-6
    5,2,7,-2
    0,7,2,-5
    -8,0,4,5
    -4,6,7,-3
    -8,8,0,-4
    -2,4,-7,-4
    1,5,-5,4
    4,4,6,-6
    7,-4,-3,3
    7,1,5,0
    1,-5,-6,-5
    -6,7,3,5
    2,6,0,-2
    7,3,-5,-7
    -3,-6,4,2
    7,0,0,-6
    -3,-5,-7,2
    1,0,6,2
    -8,1,-6,8
    3,-7,3,-2
    0,-3,0,8
    0,2,5,2
    4,3,-8,-1
    8,-2,1,5
    6,5,8,-5
    6,7,3,7
    3,-6,3,8
    -8,-5,6,0
    -2,-2,5,-7
    -5,6,-5,-6
    5,-5,6,-1
    0,2,7,5
    -2,-1,-6,2
    -8,-8,-6,6
    -5,-2,-5,1
    -4,8,-1,-2
    -6,-2,-7,-4
    -2,1,-1,-1
    -5,8,-2,0
    3,-7,-2,1
    1,-4,2,2
    5,0,-1,-1
    2,4,8,-5
    0,-3,8,1
    8,2,3,-8
    -2,8,-1,4
    3,-8,-2,8
    3,1,0,0
    8,7,-1,3
    -3,0,-6,8
    3,8,2,-7
    -7,-8,4,2
    -5,-7,-6,-8
    -7,1,8,2
    -4,2,2,0
    0,-1,6,3
    -6,1,-7,-7
    -5,1,-3,8
    -2,-1,5,-1
    3,-5,3,-5
    5,-7,-6,2
    -5,-1,0,-4
    -2,-8,3,-4
    2,2,1,0
    -3,5,0,-2
    -1,6,-4,1
    -8,8,-1,7
    -5,-7,1,7
    0,8,-5,1
    1,3,-4,4
    -6,2,-2,-5
    -7,8,7,6
    -5,-6,-2,-2
    -6,-5,0,-8
    -7,0,5,4
    -8,2,-6,0
    -1,-6,-6,-7
    0,-7,-5,0
    -2,7,-4,-2
    1,5,3,-1
    8,-8,1,-1
    8,-6,-3,5
    4,-4,8,-1
    -1,1,-4,-2
    1,-7,8,-8
    -5,-8,-1,-4
    0,-6,2,0
    -6,-8,-1,2
    8,-7,-2,-1
    0,-8,-8,0
    -1,6,-7,-8
    2,-1,-2,-2
    -6,-4,-7,-8
    3,-1,-3,8
    -5,4,-7,5
    -4,0,4,-3
    3,-7,-8,-8
    -5,-6,6,-3
    -4,-6,-8,-6
    1,2,-6,-7
    4,-4,6,4
    -8,-3,-2,3
    -1,-2,-6,3
    -6,5,2,-7
    -8,2,-3,0
    5,4,-8,7
    -2,-8,8,-5
    0,5,-1,8
    1,0,2,5
    -7,-4,-2,-5
    -5,5,-3,-7
    -4,-3,-2,-3
    -3,4,1,2
    3,-8,5,-4
    0,8,5,6
    7,8,-3,1
    0,1,6,-5
    -4,0,2,0
    7,1,3,4
    -1,1,-4,8
    3,-5,-6,1
    -3,2,-6,4
    -3,-3,-4,6
    -7,-6,-6,8
    -6,7,0,8
    2,4,3,-5
    -7,3,6,2
    4,-2,0,0
    -2,0,6,0
    -8,-2,-7,-8
    1,0,-2,-8
    -6,-4,6,8
    0,-8,-3,4
    -8,3,-1,1
    0,3,0,8
    3,4,-8,0
    -2,-7,-4,-7
    -1,6,0,8
    0,0,0,6
    5,-6,1,-4
    6,6,-8,-6
    8,5,-7,0
    8,7,-7,-5
    -3,-2,-2,-2
    0,-5,0,-8
    8,0,6,5
    8,3,6,-7
    -4,7,-3,0
    -8,-1,-5,-3
    1,8,4,0
    -8,-3,-3,7
    6,0,-7,1
    -3,0,3,-3
    -2,0,2,0
    4,-8,-8,-2
    4,4,-5,5
    6,4,0,-8
    0,0,2,-7
    -5,8,-1,0
    -4,5,-8,-1
    1,-4,-6,3
    -5,6,-2,5
    -4,-8,-5,6
    -7,2,-8,2
    3,2,-4,-7
    3,-1,2,-5
    -2,5,-5,7
    6,-2,6,-2
    6,-7,5,-4
    5,8,0,0
    -4,0,2,2
    1,6,6,-4
    -3,-4,2,0
    8,1,-1,-6
    -5,-4,-2,-3
    -2,-5,3,-2
    6,-7,-5,1
    -3,6,0,1
    -8,2,0,3
    4,2,-2,3
    -3,3,3,5
    -7,-7,-7,8
    -3,4,-3,-8
    -8,-4,8,0
    -2,-6,-4,3
    6,-2,-5,3
    -1,-1,4,-7
    -4,6,-3,5
    3,4,4,0
    -4,-5,-1,-1
    -5,6,7,1
    3,7,-4,0
    -1,2,1,8
    -2,4,0,2
    -4,0,-6,4
    2,2,-1,-1
    6,1,-7,-5
    1,-6,3,-4
    4,-6,0,7
    -2,-1,-1,2
    5,5,7,3
    6,-2,-6,-5
    -1,2,3,4
    0,-1,1,-4
    3,0,6,-1
    7,5,-1,5
    4,1,-1,-7
    4,0,-8,-7
    -3,2,8,7
    -6,-6,6,3
    1,2,-3,-7
    1,-8,3,-2
    -8,5,0,8
    3,0,-8,0
    7,3,-8,-1
    8,-3,7,-3
    3,8,0,-4
    3,2,0,0
    -5,-4,4,-5
    1,-1,8,-8
    0,0,2,-2
    -2,-5,4,-2
    7,0,3,-7
    0,-5,-6,1
    1,8,0,7
    1,8,7,-3
    -8,7,-3,5
    3,6,4,-4
    -1,2,-8,-4
    -2,-7,4,1
    7,6,7,-3
    -7,5,5,-2
    2,-8,-5,1
    -6,3,-2,-1
    -5,-1,7,-4
    0,-1,0,-1
    -3,2,-2,-6
    5,0,-5,4
    7,6,5,4
    7,1,0,-4
    7,1,0,3
    0,-3,0,-6
    -7,-2,8,1
    4,0,5,-5
    -1,6,7,-5
    -4,-6,-2,1
    -7,-1,2,2
    -5,-7,4,2
    4,1,4,-2
    4,-5,1,0
    7,4,0,-3
    -7,-7,-4,-7
    6,0,5,2
    2,-8,-7,6
    0,-6,-1,-6
    -3,-2,2,2
    -8,-4,3,-8
    3,-3,-3,-1
    5,1,2,8
    -7,-3,-4,-2
    0,0,0,0
    -7,-7,-8,-4
    -8,-5,4,-3
    1,8,7,6
    4,7,0,0
    -8,-2,1,1
    2,6,-8,-5
    1,-4,-7,3
    6,-5,0,-8
    3,6,-4,3
    -2,-1,-8,-4
    7,5,-8,-6
    -6,-4,-8,-2
    0,7,-2,7
    3,-4,-5,5
    -8,0,0,7
    6,8,0,5
    1,-8,4,-6
    1,6,-1,-1
    -5,5,0,5
    6,6,4,4
    -3,3,1,1
    5,-8,-4,-6
    0,6,1,-7
    0,7,-7,2
    4,7,-5,1
    6,8,-4,-2
    0,5,0,6
    6,-3,4,6
    2,1,-8,-2
    8,-2,-1,6
    -8,1,5,8
    -6,-7,1,7
    7,-1,1,8
    -6,0,-1,4
    -4,-3,-8,6
    0,-8,-1,-2
    1,5,8,5
    -1,-3,8,-4
    5,0,-2,-3
    -2,4,-3,3
    3,-5,0,0
    5,-6,-5,1
    8,-6,-2,1
    7,7,5,0
    4,3,5,-5
    -5,7,-2,5
    0,5,-7,-5
    0,-8,0,0
    1,6,-1,8
    -1,4,-8,3
    8,-3,5,1
    -5,8,-7,-7
    0,6,-3,6
    3,4,-3,0
    6,-6,3,8
    3,0,1,8
    -6,-2,-4,7
    -8,3,7,-5
    0,6,-7,-6
    -2,-4,6,4
    7,4,-1,-1
    0,3,-6,-5
    -6,-8,6,0
    -5,-3,2,8
    -8,2,2,3
    0,3,0,3
    2,-2,6,-4
    1,-6,8,-4
    -8,-1,-7,-1
    6,-2,0,8
    -3,-8,6,0
    -5,1,-8,1
    4,0,-4,-7
    0,-6,-7,-8
    -8,6,0,-1
    3,-5,0,-6
    4,8,-6,6
    -3,0,0,1
    -2,-3,0,3
    4,1,-1,7
    3,3,-4,-5
    -6,5,3,-3
    -7,-7,3,-2
    0,-4,-5,-7
    -8,4,-7,-7
    -6,-6,-4,-2
    7,3,-2,-5
    4,-6,5,7
    -2,4,7,2
    2,-8,4,-2
    -1,4,4,6
    7,0,0,4
    -8,3,-7,6
    6,8,7,-7
    5,8,6,0
    -2,0,-5,-7
    5,8,8,2
    0,-5,0,-5
    0,6,8,-8
    4,-5,4,-6
    -4,0,-3,-5
    -7,2,4,4
    0,0,2,-1
    -1,0,0,-5
    3,-3,-5,-8
    -2,-6,0,3
    -2,0,0,-8
    -6,-3,8,0
    -3,-8,-3,0
    6,4,5,-8
    -8,3,-3,-5
    0,-3,8,8
    -1,3,-5,5
    -2,-5,-8,0
    4,-8,-6,-6
    4,-4,0,3
    -1,-7,-1,-8
    -8,0,6,-1
    4,-4,-6,0
    8,-1,-7,1
    -5,-8,-3,6
    -2,4,-4,3
    3,-1,-1,2
    3,6,-3,8
    3,-8,0,-2
    -4,3,-5,3
    0,-3,4,1
    4,-2,4,-3
    -7,8,-4,7
    3,-2,6,7
    0,0,8,7
    2,-1,3,6
    8,3,2,-2
    1,-2,-5,7
    1,-6,0,6
    4,-3,5,8
    -8,7,-3,0
    0,-4,-1,5
    7,-3,-6,3
    5,1,1,8
    7,4,-7,-1
    7,8,3,5
    -5,6,-1,7
    5,1,6,-5
    5,-2,-3,-1
    7,-5,-3,4
    -7,4,-3,4
    4,3,0,-4
    -4,-2,2,3
    -7,3,1,-8
    -7,6,-3,-1
    5,0,6,1
    -3,3,-5,2
    -3,7,-6,4
    8,-1,-8,1
    0,-5,7,-7
    1,2,1,3
    -2,5,0,5
    -3,7,6,-5
    2,8,-1,8
    -5,-8,2,-6
    5,7,5,7
    -3,-2,0,-1
    6,2,-4,-4
    -7,0,-6,-7
    4,7,7,4
    -2,0,0,-4
    -8,6,5,-3
    """)
}