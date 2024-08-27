// Adapted from Panic's adaptation of the below! (CoreLibs/easing.lua)

//
// Adapted from
// Tweener's easing functions (Penner's Easing Equations)
// and http://code.google.com/p/tweener/ (jstweener javascript version)
//

// Disclaimer for Robert Penner's Easing Equations license:

// TERMS OF USE - EASING EQUATIONS

// Open source under the BSD License.

// Copyright © 2001 Robert Penner
// All rights reserved.

// Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

//     * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//     * Neither the name of the author nor the names of contributors may be used to endorse or promote products derived from this software without specific prior written permission.

// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

// For all easing functions:
// t = elapsed time
// b = begin
// c = change == ending - beginning
// d = duration (total time)
//
// Elastic:
// a = amplitude
// p = period
//
// Overshoot:
// s = "amount of overshoot"

typealias BasicEasingFn = (_ t: Float, _ b: Float, _ c: Float, _ d: Float) -> Float
typealias ElasticEasingFn = (_ t: Float, _ b: Float, _ c: Float, _ d: Float, _ a: Float, _ p: Float) -> Float;
typealias OvershootEasingFn = (_ t: Float, _ b: Float, _ c: Float, _ d: Float, _ s: Float) -> Float

enum EasingFn {
	case basic(BasicEasingFn)
	case elastic(ElasticEasingFn)
	case overshoot(OvershootEasingFn)
	
	func ez(_ t: Float, _ b: Float, _ c: Float, _ d: Float) -> Float {
		switch self {
		case .basic(let fn):
			return fn(t, b, c, d)
		case .elastic(let fn):
			return fn(t, b, c, d, 0.0, d * 0.3)
		case .overshoot(let fn):
			return fn(t, b, c, d, 1.70158)
		}
	}
	
	func ease(_ t: Float, _ b: Float, _ c: Float, _ d: Float, _ a_or_s: Float? = nil, p: Float? = nil) -> Float {
		switch self {
		case .basic(let fn):
			return fn(t, b, c, d)
		case .elastic(let fn):
			let amplitude = a_or_s ?? 0.0
			let period = p ?? d * 0.3
			
			return fn(t, b, c, d, period, amplitude)
		case .overshoot(let fn):
			let overshoot = a_or_s ?? 1.70158
			
			return fn(t, b, c, d, overshoot)
		}
	}
}

func linear(_ t: Float, _ b: Float, _ c: Float, _ d: Float) -> Float {
	c * t / d + b
}

func inQuad(_ t: Float, _ b: Float, _ c: Float, _ d: Float) -> Float {
	let nt = t / d;
	return c * (nt * nt) + b;
}

func outQuad(_ t: Float, _ b: Float, _ c: Float, _ d: Float) -> Float {
	let nt = t / d
	return -c * nt * (nt - 2) + b
}
