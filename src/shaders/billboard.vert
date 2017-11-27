#version 450
#extension GL_ARB_separate_shader_objects : enable

layout(set = 0, binding = 0) uniform CameraBufferObject {
    mat4 view;
	mat4 proj;
	vec4 camPos;
	vec4 camDir;
} camera;

layout(set = 1, binding = 0) uniform ModelBufferObject {
    mat4 model;
};

layout(set = 2, binding = 0) uniform Time {
    float deltaTime;
    float totalTime;
};

layout(location = 0) in vec3 inPosition;
layout(location = 1) in vec4 inColor;
layout(location = 2) in vec2 inTexCoord;
layout(location = 3) in vec3 inNormal;
layout(location = 4) in vec3 inTangent;
layout(location = 5) in vec3 inBitangent;
// Instance Buffer
layout(location = 6) in vec3 inTransformPos;
layout(location = 7) in float inScale;
layout(location = 8) in float inTheta;
layout(location = 9) in vec3 inTintColor;

layout(location = 0) out vec3 vertColor;
layout(location = 1) out vec2 fragTexCoord;
layout(location = 2) out vec3 worldPosition;
layout(location = 3) out vec3 worldN;
layout(location = 4) out vec3 worldB;
layout(location = 5) out vec3 worldT;
layout(location = 6) out float vertAmbient;
layout(location = 7) out float distanceLevel;
layout(location = 8) out vec2 noiseTexCoord;
layout(location = 9) out vec3 tintColor;

out gl_PerVertex {
    vec4 gl_Position;
};

mat4 rotateMatrix(vec3 axis, float angle)
{
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    
    return mat4(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
                oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
                oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
                0.0,                                0.0,                                0.0,                                1.0);
}

float atan2(in float y, in float x)
{
    bool s = (abs(x) > abs(y));
    return mix(3.1415926/2.0 - atan(x,y), atan(y,x), s);
}

void main() {
	mat4 rotation;
	//camDir is the right direction of the camera
	float theta = atan2(camera.camDir.z, camera.camDir.x);
	rotation = rotateMatrix(vec3(0,1,0), theta);
	mat4 translate=mat4(1.0);
	translate[3][0]=inTransformPos.x;
	translate[3][1]=inTransformPos.y;
	translate[3][2]=inTransformPos.z;

	mat4 modelMatrix = model*translate*rotation;
	mat3 inv_trans_model = transpose(inverse(mat3(modelMatrix)));
	vec3 vPos=vec3(modelMatrix * vec4(inPosition, 1.0f));
	worldN = normalize(inv_trans_model * inNormal);
	worldB = normalize(inv_trans_model * inBitangent);
	worldT = normalize(inv_trans_model * inTangent);
	vertAmbient = inColor.a;

	worldPosition = vPos;

	gl_Position = camera.proj * camera.view * vec4(vPos, 1.0);
	
    vertColor = vec3(inColor);
	//vertColor=vec3(w);
    fragTexCoord = inTexCoord;

//LOD Effect
	noiseTexCoord.x = (inPosition.x - 0.0) / 12.0f + 0.5f;
	noiseTexCoord.y = (inPosition.y - 0.0) / 20.0f;
	distanceLevel = length(vec2(camera.camPos.x, camera.camPos.z)) / (1000.0f);
	
// Tint Color
	tintColor = inTintColor;
}
