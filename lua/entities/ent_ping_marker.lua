AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
 
ENT.Category = "Ping System"

ENT.PrintName = "Ping Marker"
ENT.Author = "Aaron"
ENT.Contact = "..."
ENT.Purpose = "Mark"
ENT.Instructions = "Ping"
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:Initialize()
	if SERVER then
		self:DrawShadow(false)
		self:SetNoDraw(true)
		self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_NONE)
		timer.Simple(GetConVar("pingsystem_time"):GetInt(), function()
			if (IsValid(self)) then
				self:Remove()
			end
		end)
	end
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:Think()
	if SERVER then
		local parent = self:GetParent()
		if IsValid(parent) and (parent:IsPlayer() or parent.IsLambdaPlayer) and not parent:Alive() then
			self:Remove()
		end
	end 
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

scripted_ents.Register(ENT, "ent_ping_marker")