#version 450

layout (location = 0) in vec4 v_color;
layout (location = 1) in vec4 v_texcoord;
layout (location = 2) in vec4 v_normal;
layout (location = 3) in vec4 v_eye_dir;
layout (location = 4) in vec4 v_light_dir;

layout (binding = 1) uniform sampler2D tex0;
layout (binding = 2) uniform sampler2D tex1;
layout (binding = 3) uniform sampler2D tex2;


out vec4 FragColor;



// http://www.thetenthplanet.de/archives/1180
mat3 cotangent_frame(vec3 N, vec3 p, vec2 uv)
{
    // get edge vectors of the pixel triangle
    vec3 dp1 = dFdx( p );
    vec3 dp2 = dFdy( p );
    vec2 duv1 = dFdx( uv );
    vec2 duv2 = dFdy( uv );
 
    // solve the linear system
    vec3 dp2perp = cross( dp2, N );
    vec3 dp1perp = cross( N, dp1 );
    vec3 T = dp2perp * duv1.x + dp1perp * duv2.x;
    vec3 B = dp2perp * duv1.y + dp1perp * duv2.y;
 
    // construct a scale-invariant frame 
    float invmax = inversesqrt( max( dot(T,T), dot(B,B) ) );
    return mat3( T * invmax, B * invmax, N );
}

vec3 perturb_normal( vec3 N, vec3 V, vec2 texcoord )
{
    // assume N, the interpolated vertex normal and 
    // V, the view vector (vertex to eye)
   vec3 map = texture(tex1, texcoord ).xyz;
   map = map * 255./127. - 128./127.;
    mat3 TBN = cotangent_frame(N, -V, texcoord);
    return normalize(TBN * map);
}



void main()
{
  vec4 la0 = vec4(0.2, 0.2, 0.2, 1.0);
  vec4 ld0 = vec4(0.9, 0.85, 0.8, 1.0);
  vec4 ls0 = vec4(0.9, 0.9, 0.9, 1.0);
  vec4 mA = vec4(0.8, 0.8, 0.8, 1.0);
  vec4 mD = vec4(0.9, 0.9, 0.9, 1.0);
  vec4 mS = vec4(0.4, 0.4, 0.4, 1.0);

  vec2 uv = v_texcoord.xy;
  vec3 N = normalize(v_normal.xyz);
  vec3 L = normalize(v_light_dir.xyz);
  vec3 V = normalize(v_eye_dir.xyz);
  vec3 PN = perturb_normal(N, V, uv);
  
  vec4 c0 = texture(tex0, uv).rgba;
  // vec4 ao = texture(tex2, uv);
  vec3 final_color = vec3(0.0, 0.0, 0.0); 
  
  final_color += (la0.rgb * mA.rgb) * c0.rgb;
  float lambertTerm = dot(PN, L);
  if (lambertTerm > 0.0)
  {
    final_color += ld0.rgb * mD.rgb * lambertTerm * c0.rgb;  
    vec3 R = reflect(-L, PN);
    float specular = pow( max(dot(R, V), 0.0), 90.0);
    final_color += ls0.rgb * mS.rgb * specular;  
  }
  FragColor.rgb = final_color;
  FragColor.a = 1.0;

}
