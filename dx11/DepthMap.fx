//@author: vux
//@help: standard constant shader
//@tags: color
//@credits: 

Texture2D XYZ<string uiname="XYZ";>;
Texture2D texture2d <string uiname="Texture";>;

SamplerState g_samLinear
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};
SamplerState g_samPoint
{
    Filter = MIN_MAG_MIP_POINT;
    AddressU = Clamp;
    AddressV = Clamp;
};

 
cbuffer cbPerDraw : register( b0 )
{
	float4x4 tVP : VIEWPROJECTION;
};


cbuffer cbPerObj : register( b1 )
{
	float4x4 tW : WORLD;
	float Alpha <float uimin=0.0; float uimax=1.0;> = 1; 
	float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };
	float4x4 tTex <string uiname="Texture Transform"; bool uvspace=true; >;
	float4x4 tColor <string uiname="Color Transform";>;
};

struct VS_IN
{
	float4 PosO : POSITION;
	float4 TexCd : TEXCOORD0;

};

struct vs2ps
{
    float4 PosWVP: SV_POSITION;
    float4 TexCd: TEXCOORD0;
};

vs2ps VS(VS_IN input)
{
    vs2ps Out = (vs2ps)0;
    float4 posinfo = XYZ.SampleLevel( g_samLinear, input.TexCd.xy, 0 );
	input.PosO.x = posinfo.x;
	input.PosO.y = posinfo.z;
	input.PosO.z-= posinfo.y;
	Out.PosWVP  = mul(input.PosO,mul(tW,tVP));
    Out.TexCd = mul(input.TexCd, tTex);
    
	return Out;
}




float4 PS(vs2ps In): SV_Target
{
    float4 col = texture2d.Sample(g_samPoint,In.TexCd.xy) * cAmb;
	col = mul(col, tColor);
	col.a *= Alpha;
    return col;
}





technique10 Constant
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}




