#version 450
#extension GL_ARB_separate_shader_objects : enable

layout(set = 0, binding = 0) uniform CameraBufferObject {
    mat4 view;
	mat4 proj;
	vec3 camPos;
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

layout(location = 0) out vec3 vertColor;
layout(location = 1) out vec2 fragTexCoord;
layout(location = 2) out vec3 worldPosition;
layout(location = 3) out vec3 worldN;
layout(location = 4) out vec3 worldB;
layout(location = 5) out vec3 worldT;
layout(location = 7) out float vertAmbient;


out gl_PerVertex {
    vec4 gl_Position;
};
void ApplyMainBending(inout vec3 vPos, vec2 vWind, float fBendScale){
	// Calculate the length from the ground, since we'll need it.
	float fLength = length(vPos);
	// Bend factor - Wind variation is done on the CPU.
	float fBF = vPos.y * fBendScale;
	// Smooth bending factor and increase its nearby height limit.
	fBF += 1.0;
	fBF *= fBF;
	fBF = fBF * fBF - fBF;
	fBF = fBF * fBF;
	// Displace position
	vec3 vNewPos = vPos;
	vNewPos.xz += vWind.xy * fBF;
	vPos.xyz = normalize(vNewPos.xyz)* fLength;
}


void main() {
	mat3 inv_trans_model = transpose(inverse(mat3(model)));
	vec3 vPos=vec3(model * vec4(inPosition, 1.0f));
	worldN = normalize(inv_trans_model * inNormal);
	worldB = normalize(inv_trans_model * inBitangent);
	worldT = normalize(inv_trans_model * inTangent);
	vertAmbient = inColor.a;


	//Wind
	vec3 wind_dir = normalize(vec3(0.5, 0, 1));
    float wind_speed = 8.0;
    float wave_division_width = 5.0;
    float wave_info = (cos((dot(vec3(0, 0, 0), wind_dir) - wind_speed * totalTime) / wave_division_width) + 0.7);

	//5.1 Wind
    //directional alignment 
    //float fd = 1 - abs(dot(wind_dir, normalize(this_v2 - this_v0)));

    //height ratio
    //float fr = dot((this_v2 - this_v0), this_up) / this_h;

    //
	float wind_power = 15.0f;
    //vec3 w = wind_dir * wind_power * wave_info * fd * fr;
	vec3 w=wind_dir * wind_power * wave_info*0.05;
	vec2 Wind=vec2(w.x,w.z);



	vec3 objectPosition = vec3(0,0,0);
	vPos -= objectPosition;	// Reset the vertex to base-zero
	float BendScale=0.0009;
	ApplyMainBending(vPos, Wind, BendScale);
	vPos += objectPosition;

	mat4 scale = mat4(1.0);
	scale[0][0] = 0.01;
	scale[1][1] = 0.01;
	scale[2][2] = 0.01;
	worldPosition = vPos;

    //gl_Position = camera.proj * camera.view * model * scale * vec4(inPosition, 1.0);
	gl_Position = camera.proj * camera.view  * scale * vec4(vPos, 1.0);
	
    vertColor = vec3(inColor);
	//vertColor=vec3(w);
    fragTexCoord = inTexCoord;

}
