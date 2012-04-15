/*
 * Proland: a procedural landscape rendering library.
 * Copyright (c) 2008-2011 INRIA
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
 * Authors: Eric Bruneton, Antoine Begault, Guillaume Piolat.
 */

uniform mat4 cameraToWorld;
uniform mat4 screenToCamera;

vec3 getWorldCameraPos();
vec3 getWorldSunDir();
vec3 hdr(vec3 L);

#ifdef _VERTEX_

layout(location=0) in vec3 vertex;
out vec3 dir;
out vec3 relativeDir;

void main() {
    vec3 WSD = getWorldSunDir();

    dir = (cameraToWorld * vec4((screenToCamera * vec4(vertex, 1.0)).xyz, 0.0)).xyz;

    // construct a rotation that transforms sundir to (0,0,1);
    float theta = acos(WSD.z);
    float phi = atan(WSD.y, WSD.x);
    mat3 rz = mat3(cos(phi), -sin(phi), 0.0, sin(phi), cos(phi), 0.0, 0.0, 0.0, 1.0);
    mat3 ry = mat3(cos(theta), 0.0, sin(theta), 0.0, 1.0, 0.0, -sin(theta), 0.0, cos(theta));
    // apply this rotation to view dir to get relative viewdir
    relativeDir = (ry * rz) * dir;

    gl_Position = vec4(vertex.xy, 0.9999999, 1.0);
}

#endif

#ifdef _FRAGMENT_

#include "atmosphereShader.glhl"

uniform sampler2D glareSampler;

in vec3 dir;
in vec3 relativeDir;
layout(location=0) out vec4 data;

// assumes sundir=vec3(0.0, 0.0, 1.0)
vec3 outerSunRadiance(vec3 viewdir)
{
    vec3 data = viewdir.z > 0.0 ? texture2D(glareSampler, vec2(0.5) + viewdir.xy * 4.0).rgb : vec3(0.0);
    return pow(data, vec3(2.2)) * SUN_INTENSITY;
}

uniform vec3 origin;

uniform sampler2D transmittanceSampler;

uniform sampler2D skyIrradianceSampler;

uniform sampler3D inscatterSampler;

void main() {
    vec3 WSD = getWorldSunDir();
    vec3 WCP = getWorldCameraPos();

    vec3 d = normalize(dir);

    vec3 sunColor = outerSunRadiance(relativeDir);

    vec3 extinction;
    vec3 inscatter = skyRadiance(WCP + origin, d, WSD, extinction, 0.0);

    vec3 finalColor = sunColor * extinction + inscatter;

    data.rgb = hdr(finalColor);
}

#endif
