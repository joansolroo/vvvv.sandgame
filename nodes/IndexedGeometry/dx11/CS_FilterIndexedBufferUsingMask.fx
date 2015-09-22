
ByteAddressBuffer sobuffer;
int elementcount;
Texture2D texFilter <string uiname="Texture Filter";>;
float threshold = 0.5;
/*This is the buffer from the renderer
Renderer automatically assigns BACKBUFFER semantic
Please note we mark the buffer as append here */
AppendStructuredBuffer<uint> AppendPositionBuffer : BACKBUFFER;
SamplerState sPoint : IMMUTABLE
{
    Filter = MIN_MAG_MIP_POINT;
    AddressU = Border;
    AddressV = Border;
};

[numthreads(1,1,1)]
void CS_Clear(uint3 i : SV_DispatchThreadID)
{
	//AppendPositionBuffer.Clear();
}

[numthreads(64, 1, 1)]
void CS( uint3 i : SV_DispatchThreadID)
{ 
	//Safeguard if we don't use a multiple
	if (i.x >=  asuint(elementcount)) { return;}
	
	float x = asfloat(sobuffer.Load(i.x * 24));
	float y = asfloat(sobuffer.Load(i.x * 24 + 4));
	float z = asfloat(sobuffer.Load(i.x * 24 + 8));
	float w = asfloat(sobuffer.Load(i.x * 24 + 12));

	float2 uv = float2(asfloat(sobuffer.Load(i.x * 24 + 16)), asfloat(sobuffer.Load(i.x  * 24 + 20)));
	float mask =  texFilter.SampleLevel(sPoint,uv.xy,0).r;
	if(mask>=threshold)
	{
		AppendPositionBuffer.Append(i.x);
	}
}

technique11 FilterIDs
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}







