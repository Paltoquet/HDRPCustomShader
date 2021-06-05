Shader "Renderers/GeometryShader"
{
    Properties
    {
        _Color1("Color1", Color) = (1,1,1,1)
        _Color2("Color2", Color) = (1,1,1,1)
    }

    HLSLINCLUDE

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

    // #pragma enable_d3d11_debug_symbols

    //enable GPU instancing support
    #pragma multi_compile_instancing
    #pragma multi_compile _ DOTS_INSTANCING_ON

    ENDHLSL

    SubShader
    {
        Pass
        {
            Name "FirstPass"
            Tags { "LightMode" = "FirstPass" }

            Blend Off
            ZWrite Off
            ZTest LEqual

            Cull Back

            HLSLPROGRAM

            // List all the attributes needed in your shader (will be passed to the vertex shader)
            // you can see the complete list of these attributes in VaryingMesh.hlsl
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT

            // List all the varyings needed in your fragment shader
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_TANGENT_TO_WORLD

            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassRenderers.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/VertMesh.hlsl"

            float4 _ColorMap_ST;
            float4 _Color1;
            float4 _Color2;

            PackedVaryingsType Vert(AttributesMesh inputMesh)
            {
                VaryingsType varyingsType;
                varyingsType.vmesh = VertMesh(inputMesh);
                varyingsType.vmesh.positionCS = float4(inputMesh.positionOS, 1.0);
                return PackVaryingsType(varyingsType);
            }

            [maxvertexcount(3)]
            void Geometry(uint pid : SV_PrimitiveID, triangle PackedVaryingsType input[3], inout TriangleStream<PackedVaryingsType> outStream)
            {
                float offset = 1.0 + sin(_Time.y);

                PackedVaryingsType p0 = input[0];
                PackedVaryingsType p1 = input[1];
                PackedVaryingsType p2 = input[2];

                float3 world_0 = TransformObjectToWorld(p0.vmesh.positionCS * offset);
                float3 world_1 = TransformObjectToWorld(p1.vmesh.positionCS * offset);
                float3 world_2 = TransformObjectToWorld(p2.vmesh.positionCS * offset);

                p0.vmesh.positionCS = mul(UNITY_MATRIX_VP, float4(world_0, 1.0));
                p1.vmesh.positionCS = mul(UNITY_MATRIX_VP, float4(world_1, 1.0));
                p2.vmesh.positionCS = mul(UNITY_MATRIX_VP, float4(world_2, 1.0));

                outStream.Append(p0);
                outStream.Append(p1);
                outStream.Append(p2);
            }

            float4 Frag(PackedVaryingsToPS packedInput) : SV_Target
            {
                float offset = (sin(_Time.y) + 1.0) / 2.0;
                float4 outColor = lerp(_Color1, _Color2, offset);
                return outColor;
            }

            #pragma vertex Vert
            #pragma geometry Geometry
            #pragma fragment Frag

            ENDHLSL
        }
    }
}
