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

uniform struct {
    vec4 offset;
    vec4 camera;
    vec2 blending;
    mat4 localToScreen;
} deformation;

uniform vec2 zminmax;

#ifdef _VERTEX_

layout(location=0) in vec3 vertex;

void main() {
    float h = mix(zminmax.x, zminmax.y, vertex.z);
    vec3 p = vec3(vertex.xy * deformation.offset.z + deformation.offset.xy, h);
    gl_Position = deformation.localToScreen * vec4(p, 1.0);
}

#endif

#ifdef _FRAGMENT_

layout(location=0) out vec4 data;

void main() {
    data = vec4(1.0, 0.0, 0.0, 1.0);
}

#endif