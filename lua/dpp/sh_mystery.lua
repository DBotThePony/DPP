
--[[
Copyright (C) 2016 DBot

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Try to decode this file... IF YOU DARE!
]]

local a = '\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\95\44\44\46\46\45\45\39\39\46\62\32\32\32\32\32\32\95\32\32\32\32\32\32\32\10\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\46\96\95\95\32\32\32\32\46\58\96\46\45\39\39\45\45\46\39\47\32\32\32\32\32\32\32\10\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\46\96\32\47\32\32\92\45\45\46\46\32\32\32\32\32\32\46\39\32\96\39\45\46\32\32\32\32\32\10\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\47\32\32\40\32\47\32\32\92\95\32\32\96\45\46\32\44\39\32\32\47\32\32\32\32\96\46\32\32\32\10\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\40\32\46\45\124\32\124\32\32\32\32\96\45\46\32\32\96\45\46\95\39\32\32\32\32\32\32\32\92\32\32\10\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\46\96\32\32\40\32\39\46\32\32\92\32\95\95\96\39\39\45\45\45\39\39\39\39\96\96\45\46\32\92\32\10\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\124\32\32\32\32\92\32\32\32\95\95\47\32\32\32\95\95\92\32\32\47\32\96\58\32\32\32\32\96\39\96\10\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\124\32\32\32\32\32\92\95\32\32\40\32\32\32\47\32\46\45\124\32\124\39\46\124\32\32\32\32\32\32\32\10\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\92\96\46\32\32\32\32\32\92\44\39\92\32\40\32\40\87\87\124\32\92\87\41\106\32\32\32\32\32\32\32\10\32\32\32\32\32\32\32\32\32\32\46\46\45\45\45\39\39\39\39\39\45\45\45\32\32\32\32\32\32\32\32\32\32\32\32\32\92\32\96\46\32\32\32\32\96\45\46\92\95\92\95\96\47\32\32\32\96\96\45\46\32\32\32\32\32\32\10\32\32\32\32\32\32\32\32\44\39\32\32\32\32\95\45\45\45\45\95\95\32\32\96\39\46\32\32\32\32\32\32\32\32\32\32\32\92\32\32\96\46\32\32\60\39\45\39\96\32\32\32\32\32\32\92\95\95\47\32\32\32\32\32\32\32\10\32\32\32\32\32\32\32\47\32\32\32\95\44\39\32\32\32\32\95\95\95\96\45\46\32\32\39\46\32\32\32\32\32\32\32\32\32\32\41\32\32\32\96\46\32\96\46\45\44\95\95\95\95\95\95\46\45\39\32\32\32\32\32\32\32\32\10\32\32\32\32\32\32\124\32\46\45\39\47\32\32\32\32\46\39\32\32\32\96\96\45\96\46\32\32\58\95\95\95\95\95\95\95\95\47\32\32\32\32\32\32\92\32\32\92\32\32\47\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\10\32\32\32\32\32\32\39\96\32\32\45\32\32\32\32\32\58\32\32\32\32\46\45\39\39\62\45\39\32\32\32\32\32\92\96\45\39\32\32\46\32\32\32\47\32\124\32\32\124\40\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\10\32\32\32\32\32\32\32\32\32\32\124\32\32\32\32\58\39\32\32\32\47\32\32\32\47\32\32\32\32\32\32\32\32\32\96\45\46\45\39\74\32\32\47\32\32\124\32\32\58\32\92\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\10\32\32\32\32\32\32\32\32\32\32\124\32\32\32\46\39\32\32\32\32\124\32\32\124\32\32\84\58\58\58\84\32\32\32\32\32\46\58\39\45\45\39\32\32\32\124\32\47\32\32\32\124\32\32\32\32\32\32\32\32\32\32\32\32\32\32\10\32\32\32\32\32\32\32\32\32\46\39\32\32\32\124\32\32\32\32\32\124\32\32\124\32\32\124\58\58\58\124\32\32\32\32\32\32\32\32\32\32\32\32\32\32\124\47\32\32\32\32\124\32\32\32\32\32\32\32\32\32\32\32\32\32\32\10\32\32\32\32\32\32\32\32\32\124\32\32\32\32\124\32\32\32\32\32\124\32\32\124\32\32\92\95\58\95\47\32\32\32\32\32\32\32\32\32\32\32\32\32\32\39\32\32\32\32\32\124\32\32\32\32\32\32\32\32\32\32\32\32\32\32\10\32\32\32\32\32\32\32\32\32\124\32\32\32\32\39\46\32\32\32\32\124\32\47\32\92\32\32\32\32\32\32\32\32\47\32\32\32\32\32\32\32\32\32\32\32\32\32\92\95\95\47\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\10\32\32\32\32\32\32\32\32\32\39\46\32\32\32\32\124\32\32\32\46\39\39\32\32\32\124\32\32\32\32\32\32\47\45\44\95\95\95\95\95\95\95\92\32\32\32\32\32\32\32\92\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\10\32\32\32\32\32\32\32\32\32\32\124\32\32\32\32\124\32\32\32\124\32\32\32\95\47\32\32\32\32\32\32\47\32\32\32\32\32\124\32\32\32\32\124\92\32\32\32\32\32\32\32\92\32\32\32\32\32\32\32\32\32\32\32\32\32\32\10\32\32\32\32\32\32\32\32\32\32\124\32\32\32\46\39\32\32\32\124\32\32\47\32\32\32\32\32\32\32\47\32\32\32\32\32\124\32\32\32\32\32\124\32\96\45\45\44\32\32\32\32\92\32\32\32\32\32\32\32\32\32\32\32\32\32\10\32\32\32\32\32\32\32\32\32\46\39\32\32\32\124\32\32\32\58\32\32\32\124\32\32\32\32\32\32\124\32\32\32\32\32\32\124\32\32\32\32\32\124\32\32\32\47\32\32\32\32\32\32\41\32\32\32\32\32\32\32\32\32\32\32\32\10\32\32\32\46\95\95\46\46\39\32\32\32\32\59\96\32\32\58\92\95\95\47\124\32\32\32\32\32\32\124\32\32\32\32\32\32\124\32\32\32\32\32\32\124\32\40\32\32\32\32\32\32\32\124\32\32\32\32\32\32\32\32\32\32\32\32\10\32\32\32\32\96\45\46\95\95\95\46\45\96\59\32\32\47\32\32\32\32\32\124\32\32\32\32\32\32\124\32\32\32\32\32\32\124\32\32\32\32\32\32\124\32\32\92\32\32\32\32\32\32\124\32\32\32\32\32\32\32\32\32\32\32\32\10\32\32\32\32\32\32\32\32\32\32\32\46\58\95\45\39\32\32\32\32\32\32\124\32\32\32\32\32\32\32\92\32\32\32\32\32\124\32\32\32\32\32\32\32\92\32\32\96\46\95\95\95\47\32\32\32\32\32\32\32\32\32\32\32\32\32\10\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\92\95\95\95\95\95\95\95\41\32\32\32\32\32\92\95\95\95\95\95\95\95\41\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\10\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\10'
local f = _G['\103\101\116\102\101\110\118']
local e = '\100\112\112\95\112\111\110\121'
local q = '\77\101\115\115\97\103\101'
local H = '\46\32\67\104\101\99\107\111\117\116\32\104\116\116\112\115\58\47\47\103'
local g = '\115\116\101\114\121\32\116\104\105\110\103\115\32\58\80\32\126\32\68\66\111\116\84\104\101\80\111\110\121'
local v = '\65\71\72\33\32\89\79\85\32\70\79\85\78\68\32\77\69\33\32\89\111\117\32\119\111\110\32\116\104\105\115\32\116\105\109\101\46\32\72\97'
local u = '\118\101\32\97\32\103\111\111\100\32\116\105\109\101\32\119\105\116\104\32\111\116\104\101\114\32\109\121'
local K = '\105\116\104\117\98\46\99\111\109\47\109\98\97\115\97\103\108\105\97\47\65\83\67\73\73\45\80\111\110\121'
local j = '\112\114\105\110\116'
local d = '\68\80\80'
local s = f()
local N = s[d]
local b = '\99\111\110\99\111\109\109\97\110\100'
local m = s[b]
local c = '\65\100\100'
local T = N[q]
local l = m[c]
local i = '\73\115\86\97\108\105\100'
local h = '\83\69\82\86\69\82'
local k = s[j]

local function _________(___________, __________, ____________)
	local __________ = ___________
	if s[h] and ___________[i](__________) then return end
	k(a)
	T(v .. u .. g .. H .. K)
end

l(e, _________)
