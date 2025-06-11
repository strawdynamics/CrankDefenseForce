// Adapted from Panic's adaptation of the below. (CoreLibs/easing.lua)

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

import PlaydateKit

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
	
	func ease(_ t: Float, _ b: Float, _ c: Float, _ d: Float, _ a_or_s: Float? = nil, _ p: Float? = nil) -> Float {
		switch self {
		case .basic(let fn):
			return fn(t, b, c, d)
		case .elastic(let fn):
			let amplitude = a_or_s ?? 0.0
			let period = p ?? d * 0.3

			return fn(t, b, c, d, amplitude, period)
		case .overshoot(let fn):
			let overshoot = a_or_s ?? 1.70158
			
			return fn(t, b, c, d, overshoot)
		}
	}
}

enum Ease {
	// MARK: Basic
	
	static func linear(_ t: Float, _ b: Float, _ c: Float, _ d: Float) -> Float {
		c * t / d + b
	}

	static func inQuad(_ t: Float, _ b: Float, _ c: Float, _ d: Float) -> Float {
		let nt = t / d;
		return c * powf(nt, 2) + b;
	}

	static func outQuad(_ t: Float, _ b: Float, _ c: Float, _ d: Float) -> Float {
		let nt = t / d
		return -c * nt * (nt - 2) + b
	}

	static func inOutQuad(_ t: Float, _ b: Float, _ c: Float, _ d: Float) -> Float {
		let nt = t / d * 2
		if nt < 1 {
			return c / 2 * powf(nt, 2) + b
		} else {
			return -c / 2 * ((nt - 1) * (nt - 3) - 1) + b
		}
	}

	static func outInQuad(_ t: Float, _ b: Float, _ c: Float, _ d: Float) -> Float {
		if t < d / 2 {
			return outQuad (t * 2, b, c / 2, d)
		} else {
			return inQuad((t * 2) - d, b + c / 2, c / 2, d)
		}
	}

	static func inCubic(_ t: Float, _ b: Float, _ c: Float, _ d: Float) -> Float {
		let nt = t / d
		return c * powf(nt, 3) + b
	}

	static func outCubic(_ t: Float, _ b: Float, _ c: Float, _ d: Float) -> Float {
		let nt = t / d - 1
		return c * (powf(nt, 3) + 1) + b
	}

	static func inOutCubic(_ t: Float, _ b: Float, _ c: Float, _ d: Float) -> Float {
		var nt = t / d * 2
		if nt < 1 {
			return c / 2 * powf(nt, 3) + b
		} else {
			nt = nt - 2
			return c / 2 * (powf(nt, 3) + 2) + b
		}
	}

	static func outInCubic(_ t: Float, _ b: Float, _ c: Float, _ d: Float) -> Float {
		if t < d / 2 {
			return outCubic(t * 2, b, c / 2, d)
		} else {
			return inCubic((t * 2) - d, b + c / 2, c / 2, d)
		}
	}

	static func inQuart(_ t: Float, _ b: Float, _ c: Float, _ d: Float) -> Float {
		let nt = t / d
		return c * powf(nt, 4) + b
	}

	static func outQuart(_ t: Float, _ b: Float, _ c: Float, _ d: Float) -> Float {
		let nt = t / d - 1
		return -c * (powf(nt, 4) - 1) + b
	}

	static func inOutQuart(_ t: Float, _ b: Float, _ c: Float, _ d: Float) -> Float {
		var nt = t / d * 2
		if nt < 1 {
			return c / 2 * powf(nt, 4) + b
		}else {
			nt = nt - 2
			return -c / 2 * (powf(nt, 4) - 2) + b
		}
	}

	static func outInQuart(_ t: Float, _ b: Float, _ c: Float, _ d: Float) -> Float {
		if t < d / 2 {
			return outQuart(t * 2, b, c / 2, d)
		} else {
			return inQuart((t * 2) - d, b + c / 2, c / 2, d)
		}
	}

	static func inQuint(_ t: Float, _ b: Float, _ c: Float, _ d: Float) -> Float {
		let nt = t / d
		return c * powf(nt, 5) + b
	}

	static func outQuint(_ t: Float, _ b: Float, _ c: Float, _ d: Float) -> Float {
		let nt = t / d - 1
		return c * (powf(nt, 5) + 1) + b
	}

	static func inOutQuint(_ t: Float, _ b: Float, _ c: Float, _ d: Float) -> Float {
		var nt = t / d * 2
		if nt < 1 {
			return c / 2 * powf(nt, 5) + b
		}else {
			nt = nt - 2
			return c / 2 * (powf(nt, 5) + 2) + b
		}
	}

	static func outInQuint(_ t: Float, _ b: Float, _ c: Float, _ d: Float) -> Float {
		if t < d / 2 {
			return outQuint(t * 2, b, c / 2, d)
		} else {
			return inQuint((t * 2) - d, b + c / 2, c / 2, d)
		}
	}
	
	static func inSine(_ t: Float, _ b: Float, _ c: Float, _ d: Float) -> Float {
		return -c * cosf(t / d * (Float.pi / 2)) + c + b
	}
	
	static func outSine(_ t: Float, _ b: Float, _ c: Float, _ d: Float) -> Float {
		return c * sinf(t / d * (Float.pi / 2)) + b
	}
	
	
	static func inOutSine(_ t: Float, _ b: Float, _ c: Float, _ d: Float) -> Float {
		return -c / 2 * (cosf(Float.pi * t / d) - 1) + b
	}
	
	static func outInSine(_ t: Float, _ b: Float, _ c: Float, _ d: Float) -> Float {
		if t < d / 2 {
			return outSine(t * 2, b, c / 2, d)
		}else {
			return inSine((t * 2) - d, b + c / 2, c / 2, d)
		}
	}
	
	static func inExpo(_ t: Float, _ b: Float, _ c: Float, _ d: Float) -> Float {
		if t == 0 {
			return b
		}else {
			return c * powf(2, (10 * (t / d - 1))) + b - c * 0.001
		}
	}
	
	static func outExpo(_ t: Float, _ b: Float, _ c: Float, _ d: Float) -> Float {
		if t == d {
			return b + c
		} else {
			return c * 1.001 * (1 - powf(2, (-10 * t / d))) + b
		}
	}
	
	static func inOutExpo(_ t: Float, _ b: Float, _ c: Float, _ d: Float) -> Float {
		if t == 0 {
			return b
		}

		if t == d {
			return b + c
		}

		var nt = t / d * 2
		if nt < 1 {
			return c / 2 * powf(2, (10 * (nt - 1))) + b - c * 0.0005
		} else {
			nt = nt - 1
			return c / 2 * 1.0005 * (2 - powf(2, (-10 * nt))) + b
		}
	}
	
	static func outInExpo(_ t: Float, _ b: Float, _ c: Float, _ d: Float) -> Float {
		if t < d / 2 {
			return outExpo(t * 2, b, c / 2, d)
		} else {
			return inExpo((t * 2) - d, b + c / 2, c / 2, d)
		}
	}
	
	static func inCirc(_ t: Float, _ b: Float, _ c: Float, _ d: Float) -> Float {
		let nt = t / d
		return(-c * (sqrtf(1 - powf(nt, 2)) - 1) + b)
	}
	
	static func outCirc(_ t: Float, _ b: Float, _ c: Float, _ d: Float) -> Float {
		let nt = t / d - 1
		return(c * sqrtf(1 - powf(nt, 2)) + b)
	}
	
	static func inOutCirc(_ t: Float, _ b: Float, _ c: Float, _ d: Float) -> Float {
		var nt = t / d * 2
		if nt < 1 {
			return -c / 2 * (sqrtf(1 - powf(nt, 2)) - 1) + b
		} else {
			nt = nt - 2
			return c / 2 * (sqrtf(1 - powf(nt, 2)) + 1) + b
		}
	}
	
	static func outInCirc(_ t: Float, _ b: Float, _ c: Float, _ d: Float) -> Float {
		if t < d / 2 {
			return outCirc(t * 2, b, c / 2, d)
		} else {
			return inCirc((t * 2) - d, b + c / 2, c / 2, d)
		}
	}
	
	static func outBounce(_ t: Float, _ b: Float, _ c: Float, _ d: Float) -> Float {
		var nt = t / d
		if nt < 1 / 2.75 {
			return c * (7.5625 * nt * nt) + b
		} else if nt < 2 / 2.75 {
			nt = nt - (1.5 / 2.75)
			return c * (7.5625 * nt * nt + 0.75) + b
		} else if nt < 2.5 / 2.75 {
			nt = nt - (2.25 / 2.75)
			return c * (7.5625 * nt * nt + 0.9375) + b
		} else {
			nt = nt - (2.625 / 2.75)
			return c * (7.5625 * nt * nt + 0.984375) + b
		}
	}
	
	static func inBounce(_ t: Float, _ b: Float, _ c: Float, _ d: Float) -> Float {
		return c - outBounce(d - t, 0, c, d) + b
	}
	
	static func inOutBounce(_ t: Float, _ b: Float, _ c: Float, _ d: Float) -> Float {
		if t < d / 2 {
			return inBounce(t * 2, 0, c, d) * 0.5 + b
		} else {
			return outBounce(t * 2 - d, 0, c, d) * 0.5 + c * 0.5 + b
		}
	}
	
	static func outInBounce(_ t: Float, _ b: Float, _ c: Float, _ d: Float) -> Float {
		if t < d / 2 {
			return outBounce(t * 2, b, c / 2, d)
		} else {
			return inBounce((t * 2) - d, b + c / 2, c / 2, d)
		}
	}
	
	// MARK: Elastic
	
	static func inElastic(_ t: Float, _ b: Float, _ c: Float, _ d: Float, _ a: Float, _ p: Float) -> Float {
		if t == 0 {
			return b
		}
		
		var nt = t / d
		
		if nt == 1 {
			return b + c
		}
		
		let s: Float
		let na: Float
		
		if a < fabsf(c){
			na = c
			s = p / 4
		} else {
			na = a
			s = p / (2 * Float.pi) * asinf(c / a)
		}

		nt = nt - 1

		return -(na * powf(2, (10 * nt)) * sinf((nt * d - s) * (2 * Float.pi) / p)) + b
	}
	
	static func outElastic(_ t: Float, _ b: Float, _ c: Float, _ d: Float, _ a: Float, _ p: Float) -> Float {
		if t == 0  {
			return b
		}
		
		let nt = t / d
		
		if nt == 1  {
			return b + c
		}
		
		let s: Float
		let na: Float
		
		if a < fabsf(c) {
			na = c
			s = p / 4
		} else {
			na = a
			s = p / (2 * Float.pi) * asinf(c / a)
		}
		
		return na * powf(2,(-10 * t)) * sinf((t * d - s) * (2 * Float.pi) / p) + c + b
	}
	
	static func inOutElastic(_ t: Float, _ b: Float, _ c: Float, _ d: Float, _ a: Float, _ p: Float) -> Float {
		if t == 0 {
			return b
		}
		
		var nt = t / d * 2
		
		if nt == 2 {
			return b + c
		}
		
		let s: Float
		let na: Float
		
		if a < fabsf(c) {
			na = c
			s = p / 4
		} else {
			na = a
			s = p / (2 * Float.pi) * asinf(c / a)
		}
		
		if nt < 1 {
			nt = nt - 1
			return -0.5 * (na * powf(2, (10 * nt)) * sinf((nt * d - s) * (2 * Float.pi) / p)) + b
		} else {
			nt = nt - 1
			return na * powf(2, (-10 * nt)) * sinf((nt * d - s) * (2 * Float.pi) / p ) * 0.5 + c + b
		}
	}
	
	static func outInElastic(_ t: Float, _ b: Float, _ c: Float, _ d: Float, _ a: Float, _ p: Float) -> Float {
		if t < d / 2 {
			return outElastic(t * 2, b, c / 2, d, a, p)
		} else {
			return inElastic((t * 2) - d, b + c / 2, c / 2, d, a, p)
		}
	}
	
	// MARK: Overshoot
	
	static func inBack(_ t: Float, _ b: Float, _ c: Float, _ d: Float, _ s: Float) -> Float {
		let nt = t / d
		return c * nt * nt * ((s + 1) * nt - s) + b
	}
	
	static func outBack(_ t: Float, _ b: Float, _ c: Float, _ d: Float, _ s: Float) -> Float {
		let nt = t / d - 1
		return c * (nt * nt * ((s + 1) * nt + s) + 1) + b
	}
	
	static func inOutBack(_ t: Float, _ b: Float, _ c: Float, _ d: Float, _ s: Float) -> Float {
		let ns = s * 1.525
		var nt = t / d * 2
		if nt < 1 {
			return c / 2 * (nt * nt * ((ns + 1) * nt - ns)) + b
		} else {
			nt = nt - 2
			return c / 2 * (nt * nt * ((ns + 1) * nt + ns) + 2) + b
		}
	}
	
	static func outInBack(_ t: Float, _ b: Float, _ c: Float, _ d: Float, _ s: Float) -> Float {
		if t < d / 2 {
			return outBack(t * 2, b, c / 2, d, s)
		} else {
			return inBack((t * 2) - d, b + c / 2, c / 2, d, s)
		}
	}
}
