#version 450
#extension GL_ARB_separate_shader_objects : enable

layout(set = 1, binding = 1) uniform sampler2D texSampler;
layout(set = 1, binding = 2) uniform sampler2D normalSampler;
layout(set = 1, binding = 3) uniform sampler2D noiseSampler;

layout(set = 2, binding = 0) uniform Time {
    vec2 TimeInfo;
	// 0: deltaTime 1: totalTime
};

layout(set = 3, binding = 0) uniform LODINFO{
	// 0: LOD0 1: LOD1 2: TreeHeight 3: NumTrees
	vec4 LODInfo;
};

layout(set = 4, binding = 0) uniform DayNightInfo{
	//0: Daylength, 1: Activate
	vec2 DayNightData;
};

layout(location = 0) in vec3 vertColor;
layout(location = 1) in vec2 fragTexCoord;
layout(location = 2) in vec3 worldPosition;
layout(location = 3) in vec3 worldN;
layout(location = 4) in vec3 worldB;
layout(location = 5) in vec3 worldT;
layout(location = 6) in float vertAmbient;
layout(location = 7) in float distanceLevel;
layout(location = 8) in vec2 noiseTexCoord;
layout(location = 9) in vec3 tintColor;
layout(location = 10) in float flag;

layout(location = 0) out vec4 outColor;

const vec3 lightDir = vec3(-1.0, 5.0, -3.0);
const vec3 lightColorDay = vec3(1.0, 1.0, 0.94);
const vec3 lightColorAfternoon = vec3(1.0, 0.9, 0.7);
const vec3 lightColorNight = vec3(0.95, 1.0, 1.0);

void main() {
	// LOD Morphing
	vec4 noiseColor = texture(noiseSampler, noiseTexCoord);
	float dis = (distanceLevel - LODInfo.y)/(LODInfo.x - LODInfo.y);
	if(dis < noiseColor.x)
		discard;

	// Local normal, in tangent space
	vec3 TextureNormal_tangentspace;
	TextureNormal_tangentspace = (texture( normalSampler, fragTexCoord ).rgb*2.0f - 1.0f);
	TextureNormal_tangentspace.x *= 1.1f;
	// Modify the bugs on original texture
	TextureNormal_tangentspace.y *= clamp(worldPosition.y/15.0f, 0.5f, 1.0f);
	vec3 TextureNormal_worldspace = normalize(worldT * TextureNormal_tangentspace.x + worldB * TextureNormal_tangentspace.y + worldN * TextureNormal_tangentspace.z);

    vec4 diffuseColor = texture(texSampler, fragTexCoord);
	
	//Because the alpha level fake tree billboard we use here is different with models' billboards
	float alphaThreshold = (0.85f-0.55f*flag);
	if(diffuseColor.a < alphaThreshold)
		discard;

	// Calculate the diffuse term for Lambert shading
	float diffuseTerm = clamp(dot(TextureNormal_worldspace, normalize(lightDir)), 0.15f, 1);
	// Avoid negative lighting values
	float ambientTerm = vertAmbient * (0.15f) + 0.2f*flag;

	// Day and Night Cycle
	float dayLength = DayNightData.x;
	float currentTime = TimeInfo[1] - (dayLength * floor(TimeInfo[1]/dayLength));
	float lightIntensity = 1.0f;
	vec3 lightColor;
	if(currentTime < (dayLength/4.0)){
		lightColor = lightColorDay * (1.0 - (currentTime)/(dayLength/4.0)) + lightColorAfternoon * (currentTime)/(dayLength/4.0); 
		lightIntensity = 1.1f * (1.0 - (currentTime)/(dayLength/4.0)) + 0.9f * (currentTime)/(dayLength/4.0);
	}
	else if(currentTime < (dayLength/2.0)){
		lightColor = lightColorAfternoon * (1.0 - (currentTime-(dayLength/4.0))/(dayLength/4.0)) + lightColorNight * (currentTime-(dayLength/4.0))/(dayLength/4.0); 
		lightIntensity = 0.9f * (1.0 - (currentTime-(dayLength/4.0))/(dayLength/4.0)) + 0.4f * (currentTime-(dayLength/4.0))/(dayLength/4.0);
	}
	else{
		lightColor = lightColorNight * (1.0 - (currentTime-(dayLength/2.0))/(dayLength/2.0)) + lightColorDay * (currentTime-(dayLength/2.0))/(dayLength/2.0); 
		lightIntensity = 0.4f * (1.0 - (currentTime-(dayLength/2.0))/(dayLength/2.0)) + 1.1f * (currentTime-(dayLength/2.0))/(dayLength/2.0);
	}

	float dayNightAct = DayNightData.y;
	lightColor = lightColor * dayNightAct + lightColorDay * (1.0f - dayNightAct);
	lightIntensity = lightIntensity * dayNightAct + 1.0f * (1.0f - dayNightAct);
	//Because there is no normal map of fake tree billboard here
	outColor = vec4(diffuseColor.rgb * tintColor * lightColor * lightIntensity *((diffuseTerm + ambientTerm)*(1 - flag) + 1.2f*flag), diffuseColor.a);
	//outColor=vec4(0.0f, abs(test[2]), 0.0f,1.0);
}
