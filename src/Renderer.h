#pragma once

#include "Device.h"
#include "SwapChain.h"
#include "Scene.h"
#include "Camera.h"

class Renderer {
public:
    Renderer() = delete;
    Renderer(Device* device, SwapChain* swapChain, Scene* scene, Camera* camera);
    ~Renderer();

    void CreateCommandPools();

    void CreateRenderPass();

// Funcs: Descriptor Set Layout
    void CreateCameraDescriptorSetLayout();
    void CreateModelDescriptorSetLayout();
    void CreateGrassDescriptorSetLayout();
	void CreateTimeDescriptorSetLayout();
	void CreateWindDescriptorSetLayout();
	void CreateDayNightDescriptorSetLayout();
	void CreateComputeDescriptorSetLayout();
	void CreateCullingComputeDescriptorSetLayout();
	void CreateFakeCullingComputeDescriptorSetLayout();
	void CreateSkyboxDescriptorSetLayout();
	void CreateTerrainDescriptorSetLayout();
	void CreateLODInfoDescriptorSetLayout();
	void CreateGuiDescriptorSetLayout();


    void CreateDescriptorPool();

// Funcs: Descriptor Set
    void CreateCameraDescriptorSet();
    void CreateModelDescriptorSets();
    void CreateGrassDescriptorSets();
	void CreateTimeDescriptorSet();
	void CreateWindDescriptorSet();
	void CreateDayNightDescriptorSet();
	void CreateComputeDescriptorSets();
	void CreateCullingComputeDescriptorSets();
	void CreateFakeCullingComputeDescriptorSets();
	void CreateSkyboxDescriptorSet();
	void CreateTerrainDescriptorSet();
	void CreateLODInfoDescriptorSets();
	void CreateGuiDescriptorSets();

// Funcs: Pipeline(Correspond to how many different shaders)
    void CreateGraphicsPipeline();
    void CreateGrassPipeline();
    void CreateComputePipeline();
	void CreateCullingComputePipeline();
	void CreateFakeCullingComputePipeline();
	void CreateBarkPipeline();
	void CreateLeafPipeline();
	void CreateBillboardPipeline();
	void CreateSkyboxPipeline();
	void CreateTerrainPipeline();
	void CreateGuiPipeline();

    void CreateFrameResources();
    void DestroyFrameResources();
    void RecreateFrameResources();

    void RecordCommandBuffers();
    void RecordComputeCommandBuffer();

    void Frame();

private:
    Device* device;
    VkDevice logicalDevice;
    SwapChain* swapChain;
    Scene* scene;
    Camera* camera;

    VkCommandPool graphicsCommandPool;
    VkCommandPool computeCommandPool;

    VkRenderPass renderPass;


// Vars: Descriptor Set Layout
	VkDescriptorSetLayout cameraDescriptorSetLayout;
	VkDescriptorSetLayout modelDescriptorSetLayout;
	VkDescriptorSetLayout grassDescriptorSetLayout;
	VkDescriptorSetLayout timeDescriptorSetLayout;
	VkDescriptorSetLayout windDescriptorSetLayout;
	VkDescriptorSetLayout dayNightDescriptorSetLayout;
	VkDescriptorSetLayout computeDescriptorSetLayout;
	VkDescriptorSetLayout cullingComputeDescriptorSetLayout;
	VkDescriptorSetLayout fakeCullingComputeDescriptorSetLayout;
	VkDescriptorSetLayout skyboxDescriptorSetLayout;
	VkDescriptorSetLayout terrainDescriptorSetLayout;
	VkDescriptorSetLayout LODInfoDescriptorSetLayout;
	VkDescriptorSetLayout GuiDescriptorSetLayout;

	VkDescriptorPool descriptorPool;

// Vars: Descriptor Set
	VkDescriptorSet cameraDescriptorSet;
	std::vector<VkDescriptorSet> modelDescriptorSets;
	VkDescriptorSet timeDescriptorSet;
	VkDescriptorSet windDescriptorSet;
	VkDescriptorSet dayNightDescriptorSet;
	std::vector<VkDescriptorSet> grassDescriptorSets;
	std::vector<VkDescriptorSet> computeDescriptorSets;
	std::vector<VkDescriptorSet> cullingComputeDescriptorSets;
	std::vector<VkDescriptorSet> fakeCullingComputeDescriptorSets;
	VkDescriptorSet skyboxDescriptorSet;
	VkDescriptorSet terrainDescriptorSet;
	std::vector<VkDescriptorSet> LODInfoDescriptorSets;
	VkDescriptorSet guiDescriptorSet;

// Vars: Pipeline Layout and pipeline
	VkPipelineLayout graphicsPipelineLayout;
	VkPipelineLayout barkPipelineLayout;
	VkPipelineLayout leafPipelineLayout;
	VkPipelineLayout billboardPipelineLayout;
	VkPipelineLayout grassPipelineLayout;
	VkPipelineLayout computePipelineLayout;
	VkPipelineLayout cullingComputePipelineLayout;
	VkPipelineLayout fakeCullingComputePipelineLayout;
	VkPipelineLayout skyboxPipelineLayout;
	VkPipelineLayout terrainPipelineLayout;
	VkPipelineLayout guiPipelineLayout;

	VkPipeline graphicsPipeline;
	VkPipeline barkPipeline;
	VkPipeline leafPipeline;
	VkPipeline billboardPipeline;
	VkPipeline grassPipeline;
	VkPipeline computePipeline;
	VkPipeline cullingComputePipeline;
	VkPipeline fakeCullingComputePipeline;
	VkPipeline skyboxPipeline;
	VkPipeline terrainPipeline;
	VkPipeline guiPipeline;

    std::vector<VkImageView> imageViews;
    VkImage depthImage;
    VkDeviceMemory depthImageMemory;
    VkImageView depthImageView;
    std::vector<VkFramebuffer> framebuffers;

    std::vector<VkCommandBuffer> commandBuffers;
    VkCommandBuffer computeCommandBuffer;
};
