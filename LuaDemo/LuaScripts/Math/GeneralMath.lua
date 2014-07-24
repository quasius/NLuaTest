--[[
A collection of common "static" math functions that don't fit into any class.

STATIC MEMBERS:
d2Pi					2 * pi
dDegreesToRadians		pi / 180.0
dRadiansToDegrees		180.0 / pi


METHODS:
ApproxEqual		Returns if the 2 passed numbers are within a 3rd specified value (inclusive) of each other (0.00001 if unspecified)
ApproxGreaterOrEqual	Returns if dNumber1 is greater than or equal to dNumber2 within a 3rd specified value (inclusive) of each other (0.000001 if unspecified)
ApproxLessOrEqual		Returns if dNumber1 is less than or equal to dNumber2 within a 3rd specified value (inclusive) of each other (0.000001 if unspecified)
Round			Returns the passed number rounded to the nearest integer.  (x.5 rounds to x + 1)
RoundToNearest	Returns the passed numbed rounded to the nearest dInterval with midpoints rounded up.  (RoundToNearest(3.6, 0.5) will return 3.5)
NormalizeAngleDegrees	Returns the passed angle in degrees normalized to the range 0 to 360
NormalizeAngleRadians	Returns the passed angle in radians normalized to the range 0 to 2*pi
GetNumIntegerDigits		Returns the number of integer base-10 digits for the passed number.  0 return 1
GetRandomInt			Returns a uniformly-distributed pseudo-random int over the passed inclusive interval
GetRandomDouble			Returns a uniformly-distributed pseudo-random double over the passed inclusive interval
--]]


if DEBUG then
	DeclareGlobal("GeneralMath", {})
else
	GeneralMath = {}
end

GeneralMath.__index = GeneralMath


--Init static members
GeneralMath.d2Pi = math.pi * 2.0
GeneralMath.dDegreesToRadians = math.pi / 180.0
GeneralMath.dRadiansToDegrees = 180.0 / math.pi


--Returns if the 2 passed numbers are within a 3rd specified value (inclusive) of each other (0.000001 if unspecified)
function GeneralMath.ApproxEqual(dNumber1, dNumber2, dEpsilon)	
	local epsilon = dEpsilon or 0.000001
	return math.abs(dNumber1 - dNumber2) <= epsilon
end


--Returns if dNumber1 is greater than or equal to dNumber2 within a 3rd specified value (inclusive) of each other (0.000001 if unspecified)
function GeneralMath.ApproxGreaterOrEqual(dNumber1, dNumber2, dEpsilon)
	local epsilon = dEpsilon or 0.000001
	return dNumber1 >= dNumber2 or math.abs(dNumber1 - dNumber2) <= epsilon
end

--Returns if dNumber1 is less than or equal to dNumber2 within a 3rd specified value (inclusive) of each other (0.000001 if unspecified)
function GeneralMath.ApproxLessOrEqual(dNumber1, dNumber2, dEpsilon)
	local epsilon = dEpsilon or 0.000001
	return dNumber1 <= dNumber2 or math.abs(dNumber1 - dNumber2) <= epsilon
end


--Returns the passed number rounded to the nearest integer.  (x.5 rounds to x + 1)
function GeneralMath.Round(dNumber)
	local dRoundedNumber = math.floor(dNumber)
	if dNumber - dRoundedNumber >= 0.5 then
		return dRoundedNumber + 1.0
	end
	
	return dRoundedNumber	
end

--Returns the passed numbed rounded to the nearest dInterval with midpoints rounded up.  (RoundToNearest(3.6, 0.5) will return 3.5)
function GeneralMath.RoundToNearest(dNumber, dInterval)
	local dRemainder = math.fmod(dNumber, dInterval)

	--Start by rounding "down"
	local dRoundedNumber = dNumber - dRemainder
	
	--If the remainder is at least half the interval, we need to round "up"
	if math.abs(dRemainder) >= dInterval / 2.0 then
		if dNumber >= 0.0 then
			dRoundedNumber = dRoundedNumber + dInterval
		else
			dRoundedNumber = dRoundedNumber - dInterval
		end
	end
	
	return dRoundedNumber
end


--Returns the passed angle in degrees normalized to the range 0 to 360
function GeneralMath.NormalizeAngleDegrees(dDegrees)
	local dNormalizedAngleDegrees = dDegrees % 360.0
	if dNormalizedAngleDegrees < 0.0 then
		dNormalizedAngleDegrees = dNormalizedAngleDegrees + 360.0
	end

	return dNormalizedAngleDegrees;
end

--Returns the passed angle in radians normalized to the range 0 to 2*pi
function GeneralMath.NormalizeAngleRadians(dRadians)
	local d2Pi = GeneralMath.d2Pi
	local dNormalizedAngleRadians = dRadians % d2Pi
	if dNormalizedAngleRadians < 0.0 then
		dNormalizedAngleRadians = dNormalizedAngleRadians + d2Pi
	end

	return dNormalizedAngleRadians;
end


--Returns the number of integer base-10 digits for the passed number.  0 return 1
function GeneralMath.GetNumIntegerDigits(nNumber)
	--Handle 0.x case
	if nNumber < 1 then
		return 1
	end
	
	local nNumDigits = 0
	while nNumber >= 1.0 do
		nNumDigits = nNumDigits + 1
		nNumber = nNumber * 0.1
	end

	return nNumDigits
end


--Returns a uniformly-distributed pseudo-random int over the passed inclusive interval
function GeneralMath.GetRandomInt(nMin, nMax)
	local lGeneralMath = GeneralMath
	return lGeneralMath.RoundToNearest(lGeneralMath.GetRandomDouble(nMin, nMax))
end

--Returns a uniformly-distributed pseudo-random double over the passed inclusive interval
function GeneralMath.GetRandomDouble(dMin, dMax)
	return (math.random() * (dMax - dMin)) + dMin
end
