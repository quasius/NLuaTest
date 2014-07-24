--[[
A class representing a 2D vector of numbers (double-precision floats).

MEMBERS:
x	The x-coordinate
y	The y-coordinate

METHODS:
New				Overloaded constructor.  0 arguments = default 0,0.  1 argument (Vec2D) = copy constructor.  2 arguments (number) = full constructor.
ApproxEqual		Static function that returns if v2d1's components are both within dEpsilon of v2d2's components
RoundThis		Rounds the values of this Vec2D to the nearest integer.
GetRound		Returns a new Vec2D that has both values rounded to the nearest integer
Magnitude		Returns the magnitude of this vector
MagnitudeSquared	Returns the square of the magnitude of this vector.  (Cheaper than actual magnitude and still useful for comparisons)
DotProduct		Returns the dot product of this and the passed vector
GetOrthogonalVector		Returns a vector orthogonal to this.  (2D analogue of the 3D "cross product")
AngleBetweenVector	Finds the smallest angle in radians between this and the passed vector
AngleToVector		Finds the angle in radians from this to the passed vector.
GetAngleFromPositiveX	Returns the angle in radians of this vector from the positive x-axis.
DistanceToPoint		Returns the distance from this to the passed Vec2d
DistanceToPointSquared	Returns the square of distance from this (treated as a point) to the passed 2D point.  (Faster than DistanceToPoint)
DistanceToLine		Returns the distance from this to the nearest point on the passed line.  (Always >= 0)
DistanceToLineSegment	Returns the distance from this to the nearest point on the passed line segment.  (Always >= 0)
GetSideOfLine	Find which side of the passed directional line this is on.  (The order of the points in the line matters.)
InterpolateToVector		Returns a new vector linerally interpolated between this and the passed vector at the passed interpolation fraction.
ComponentWiseMultiply	Returns a vector that is (self.x * passed.x, self.y * passed.y)
ComponentWiseDivide		Returns a vector that is (self.x / passed.x, self.y / passed.y)
__add			addition metamethod
__sub			subtraction metamethod
__mul			multiplication metamethod (scalar multiplication)
__div			division metamethod (scalar division)
__unm			negation metamethod
__eq			equality metamethod
__tostring		string-conversion metamethod
__concat		string concatination metamethod
--]]

--package.path = package.path .. ";" .. os.getenv("HOME") .. "/.imapfilter/?.lua"

require "Math.GeneralMath"
--require "././LuaScripts.Math.GeneralMath"


if DEBUG then
	DeclareGlobal("Vec2D", {})
else
	Vec2D = {}
end

Vec2D.__index = Vec2D



--Constructor
--If no arguments are passed, will set values to defualt (0,0)
--If only copyOrX is passed, will expect it to be a Vec2D and will act as a copy constructor
--If both arguments are passed, will set new Vec2D to passed number values
function Vec2D.New(copyOrX, y)
	local newVec2D = {}             -- our new object
	setmetatable(newVec2D, Vec2D)
	
	--No arguments, so default 0
	if copyOrX == nil then
		newVec2D.x = 0.0
		newVec2D.y = 0.0
	--Only first argument, so copy constructor
	elseif y == nil then
		newVec2D.x = copyOrX.x
		newVec2D.y = copyOrX.y
	--Fully specified constructor
	else
		newVec2D.x = copyOrX
		newVec2D.y = y
	end

	return newVec2D
end


--Static function that returns if v2d1's components are both within dEpsilon of v2d2's components
function Vec2D.ApproxEqual(v2d1, v2d2, dEpsilon)
	local approxEqual = GeneralMath.ApproxEqual
	return (approxEqual(v2d1.x, v2d2.x, dEpsilon) and approxEqual(v2d1.y, v2d2.y, dEpsilon))
end


--Rounds the values of this Vec2D to the nearest integer.
function Vec2D:RoundThis()
	self.x = GeneralMath.Round(self.x)
	self.y = GeneralMath.Round(self.y)
end

--Returns a new Vec2D that has both values rounded to the nearest integer
function Vec2D:GetRound()
	local lRound = GeneralMath.Round
	return Vec2D.New(lRound(self.x), lRound(self.y))
end

--Returns the magnitude of this vector
function Vec2D:Magnitude()
	return math.sqrt((self.x * self.x) + (self.y * self.y))
end


--Returns the square of the magnitude of this vector.  (Cheaper than actual magnitude and still useful for comparisons)
function Vec2D:MagnitudeSquared()
	return (self.x * self.x) + (self.y * self.y)
end


--Returns the dot product of this and the passed vector
function Vec2D:DotProduct(vec2d)
	return (self.x * vec2d.x) + (self.y * vec2d.y)
end


--Returns a vector orthogonal to this.  (2D analogue of the 3D "cross product")
--Returns the vector such that this is equivalent to rotating this (as a point) pi / 2 clockwise about the origin
function Vec2D:GetOrthogonalVector()
	return Vec2D.New(self.y, -self.x)
end


--Finds the smallest angle in radians between this and the passed vector
function Vec2D:AngleBetweenVector(vec2d)
	local dDotProduct = self:DotProduct(vec2d)
	local dMagnitudesProduct = self:Magnitude() * vec2d:Magnitude()
	
	if DEBUG then
		assert(not GeneralMath.ApproxEqual(dMagnitudesProduct, 0.0))
	end
	
	return math.acos(dDotProduct / dMagnitudesProduct)
end

--Finds the angle in radians from this to the passed vector.
--Clockwise is positive
--Returns a result from 0 to 2*pi
--Gives undefined results if magnitude of either vector is 0
function Vec2D:AngleToVector(vec2d)
	local dAngleFromPosXToThis = self:GetAngleFromPositiveX();
	local dAngleFromPosXToThat = vec2d:GetAngleFromPositiveX();

	local dAngle = dAngleFromPosXToThat - dAngleFromPosXToThis;
	
	--Normalize result
	if dAngle < 0.0 then
		dAngle = dAngle + math.pi2;
	end
		
	return dAngle;
end


--Returns the angle in radians of this vector from the positive x-axis.
--Positive x-axis is 0 radians and positive rotation is clockwise.
--Returns a value from 0 to 2*pi
--Returns 0.0f if this vector has magnitude 0.
function Vec2D:GetAngleFromPositiveX()
	--First get the angle between this and positive x.  (acos(dot / magnitudes product))
	local dMagnitude = self:Magnitude()
	
	--Make sure we have non-0 magnitude
	if GeneralMath.ApproxEqual(dMagnitude, 0.0) then
		return 0.0
	end

	--The dot product of this with (1.0f, 0.0f) is simply x and it's magnitude is 1
	local dAngle = math.acos(self.x / dMagnitude);
	
	
	--If the vector is in the -y half we need to compliment the raw angle with 2*pi
	if self.y > 0.0 then
		dAngle = math.pi2 - dAngle;
	end
	
	--Make positive be clockwise
	dAngle = math.pi2 - dAngle

	return dAngle;
end


--Returns the distance from this (treated as a point) to the passed 2D point
function Vec2D:DistanceToPoint(v2dPoint)
	return math.sqrt(((v2dPoint.x - self.x) * (v2dPoint.x - self.x)) + ((v2dPoint.y - self.y) * (v2dPoint.y - self.y)))
end

--Returns the square of distance from this (treated as a point) to the passed 2D point.
--Faster than DistanceToPoint since it avoids a sqrt and can still be used for relative distances.
function Vec2D:DistanceToPointSquared(v2dPoint)
	return ((v2dPoint.x - self.x) * (v2dPoint.x - self.x)) + ((v2dPoint.y - self.y) * (v2dPoint.y - self.y))
end


--Returns the distance from this to the nearest point on the passed line.  (Always >= 0)
function Vec2D:DistanceToLine(line)
	local dx = line.v2dPoint2.x - line.v2dPoint1.x
	local dy = line.v2dPoint2.y - line.v2dPoint1.y

	--Make sure the line points are different
	if dx == 0 and dy == 0 then
		return 0
	end

	--Get normalized slope
	local dLength = math.sqrt((dx * dx) + (dy * dy))
	local dNormDx = dx / dLength
	local dNormDy = dy / dLength

	--dist_from_line = math.abs(dNormDx * (line.Y1 - y) - dNormDy *(line.X1 - x));
	return math.abs(dNormDx * (line.v2dPoint1.y - self.y) - dNormDy * (line.v2dPoint1.x - self.x))
end

--Returns the distance from this to the nearest point on the passed line segment.  (Always >= 0)
function Vec2D:DistanceToLineSegment(lineSegment)
	--get the square of the line segment length.  (Avoids a sqrt)
	local v2dEndPointDifference = lineSegment.v2dPoint2 - lineSegment.v2dPoint1
	local dLength = v2dEndPointDifference:Magnitude()
	local dLengthSquared = fLength * fLength
	
	--If endpoints are equal, return the distence to either
	if dLengthSquared == 0 then
		return self:DistanceToPoint(lineSegment.v2dPoint1)
	end
		
	--Consider the line extending the segment, parameterized as:  v2EndPoint1 - (t * (v2dEndPoint2 - v2DEndPoint1))
	--Find the projection of v2fPoint onto that line:
	--  It falls where t = DotProduct(v2fPoint - v2DEndpoint1, v2DEndPoint2 - v2DEndPoint1) / fLengthSquared;
	local t = v2dEndPointDifference:DotProduct(self - lineSegment.v2dPoint1) / dLengthSquared
	
	--Before the lineSegment.v2dPoint1 end of the segment
	if t < 0 then
		return self:DistanceToPoint(lineSegment.v2dPoint1)
	end
		
	--After the lineSegment.v2dPoint2 end of the segment
	if t > 1 then
		return self:DistanceToPoint(lineSegment.v2dPoint2)
	end
	
	--Inside the line segment
	local v2dProjection = lineSegment.v2dPoint1 + (t * v2dEndPointDifference)
	return self:DistanceToPoint(v2dProjection)
end

	
--Find which side of the passed directional line this is on.  (The order of the points in the line matters.)
--Returns a negative value if this is "to the left" of the line, zero if it's on the line, and a positive value if it's "to the right".
function Vec2D:GetSideOfLine(line)
	--[[
	--Line is (x1,y1) to (x2,y2), point is (x3,y3).
	float linePointPosition2D ( float x1, float y1, float x2, float y2, float x3, float y3 )
	{
		return (x2 - x1) * (y3 - y1) - (y2 - y1) * (x3 - x1);
	}
	--]]

	return (((line.v2dPoint2.x - line.v2dPoint1.x) * (self.y - line.v2dPoint1.y)) - ((line.v2dPoint2.y - line.v2dPoint1.y) * (self.x - line.v2dPoint1.x)))
end


--Returns a new vector linerally interpolated between this and the passed vector at the passed interpolation fraction.
function Vec2D:InterpolateToVector(vec2d, dInterpolationFraction)
	return self + ((vec2d - self) * dInterpolationFraction)
end


--Returns a vector that is (self.x * passed.x, self.y * passed.y)
function Vec2D:ComponentWiseMultiply(vec2d)
	return self.New(self.x * vec2d.x, self.y * vec2d.y)
end

--Returns a vector that is (self.x / passed.x, self.y / passed.y)
function Vec2D:ComponentWiseDivide(vec2d)
	return self.New(self.x / vec2d.x, self.y / vec2d.y)
end


--Static function that finds how much of a desired movement (v2dDesiredMovement) is allowed given a current accumulated allowed movement (v2dAccumulatedAllowedMovement) and a new movement restriction (v2dCurrentAllowedMovement)
--Does not return a value, but directly modifies v2dAccumulatedAllowedMovement
--Used inside of loops to aggregate movement restrictions from multiple sources.
function Vec2D.AccumulateAllowedMovement(v2dDesiredMovement, v2dCurrentAllowedMovement, v2dAccumulatedAllowedMovement)	
	if (v2dDesiredMovement.x > 0 and v2dCurrentAllowedMovement.x < v2dAccumulatedAllowedMovement.x) or (v2dDesiredMovement.x < 0 and v2dCurrentAllowedMovement.x > v2dAccumulatedAllowedMovement.x) then
		v2dAccumulatedAllowedMovement.x = v2dCurrentAllowedMovement.x
	end
	if (v2dDesiredMovement.y > 0 and v2dCurrentAllowedMovement.y < v2dAccumulatedAllowedMovement.y) or (v2dDesiredMovement.y < 0 and v2dCurrentAllowedMovement.y > v2dAccumulatedAllowedMovement.y) then
		v2dAccumulatedAllowedMovement.y = v2dCurrentAllowedMovement.y
	end
end


--Add metamethod
function Vec2D.__add(v2d1, v2d2)
	return Vec2D.New(v2d1.x + v2d2.x, v2d1.y + v2d2.y)
end

--Subtract metamethod
function Vec2D.__sub(v2d1, v2d2)
	return Vec2D.New(v2d1.x - v2d2.x, v2d1.y - v2d2.y)
end

--Multiply metamethod (scalar multiply)
function Vec2D.__mul(op1, op2)
	if getmetatable(op1) == Vec2D then
		return Vec2D.New(op1.x * op2, op1.y * op2)
	end
	
	return Vec2D.New(op2.x * op1, op2.y * op1)
end

--Divide metamethod (scalar divide)
function Vec2D.__div(v2d, dDenominator)	
	return Vec2D.New(v2d.x / dDenominator, v2d.y / dDenominator)
end

--Negation metamethod
function Vec2D.__unm(v2d)
	return Vec2D.New(-v2d.x, -v2d.y)
end

--Equality metamethod
function Vec2D.__eq(op1, op2)
	return (op1.x == op2.x and op1.y == op2.y)
end

--tostring metamethod
function Vec2D.__tostring(v2d)
	return "(" .. v2d.x .. ", " .. v2d.y .. ")"
end

--concat metamethod
function Vec2D.__concat(op1, op2)
	if getmetatable(op1) == Vec2D and getmetatable(op2) == Vec2D then
		return Vec2D.__tostring(op1) .. Vec2D.__tostring(op2)
	elseif getmetatable(op1) == Vec2D then
		return Vec2D.__tostring(op1) .. op2
	else
		return op1 .. Vec2D.__tostring(op2)
	end
end


--Some static instances
Vec2D.v2dZero = Vec2D.New(0.0, 0.0)
Vec2D.v2dOne = Vec2D.New(1.0, 1.0)
Vec2D.v2dPosX = Vec2D.New(1.0, 0.0)
Vec2D.v2dNegX = Vec2D.New(-1.0, 0.0)
Vec2D.v2dPosY = Vec2D.New(0.0, 1.0)
Vec2D.v2dNegY = Vec2D.New(0.0, -1.0)
