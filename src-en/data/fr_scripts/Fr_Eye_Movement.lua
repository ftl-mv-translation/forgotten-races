mods.eyesystem = {}

local eye = mods.eyesystem

eye.pupil = {
    storedTexture = Hyperspace.Resources:GetImageId("lua_textures/precursor_pupil.png"),
    texture = "precursor_pupil",
    baseX = 250,
    baseY = 190,
    x = 0,
    y = 0,
    radius = 10,
    maxRadius = 1000,
    angle = 0,
    alpha = 1.0
}

eye.iris = {
    storedTexture = {Hyperspace.Resources:GetImageId("lua_textures/precuror_iris_1.png"), Hyperspace.Resources:GetImageId("lua_textures/precuror_iris_2.png"), Hyperspace.Resources:GetImageId("lua_textures/precuror_iris_3.png"), Hyperspace.Resources:GetImageId("lua_textures/precuror_iris_4.png")},
    texture = "precuror_iris",
    textureIndex = 1,
    baseX = 210,
    baseY = 150,
    x = 0,
    y = 0,
    radius = 40,
    maxRadius = 1000,
    angle = 0,
    alpha = 1.0
}

eye.target = {
    x = 0,
    y = 0
}

function eye.distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

function eye.getIrisPosition(force)
    local iris = eye.iris
    local target = eye.target
    local destination = {x = 0, y = 0}

    destination.x = iris.baseX + (target.x - iris.baseX) * iris.radius / iris.maxRadius
    destination.y = iris.baseY + (target.y - iris.baseY) * iris.radius / iris.maxRadius

    return destination
end

function eye.getPupilPosition(force)
    local irisPos = eye.getIrisPosition()
    local pupil = eye.pupil
    local target = eye.target
    local destination = {x = 0, y = 0}

    destination.x = irisPos.x + 40 + (target.x - pupil.baseX) * pupil.radius / pupil.maxRadius
    destination.y = irisPos.y + 40 + (target.y - pupil.baseY) * pupil.radius / pupil.maxRadius

    return destination
end

function eye.renderPupil(angle, x, y)
    local pupil = eye.pupil

    Hyperspace.Resources:RenderImage(pupil.storedTexture, x, y, angle, Graphics.GL_Color(1, 1, 1, 1), pupil.alpha, false)
    pupil.angle = angle
    pupil.x = x
    pupil.y = y
end

function eye.renderIris(angle, x, y)
    local iris = eye.iris
    --iris.storedTexture = Hyperspace.Resources:GetImageId(iris.texture.."_1.png")

    Hyperspace.Resources:RenderImage(iris.storedTexture[iris.textureIndex], x, y, angle, Graphics.GL_Color(1, 1, 1, 1), iris.alpha, false)
    iris.angle = angle
    iris.x = x
    iris.y = y
end


