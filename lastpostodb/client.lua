--Version 1.4
RegisterNetEvent('projectEZ:notify')
RegisterNetEvent("projectEZ:spawnlaspos")

Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local autoSave = false -- Active automatique 
local timerofsave = 60000 -- Durée entre chaque sauvegarde de la position 60000 = 60 secondes
local spamdelay = 60000 -- Durée d'attente avant de pouvoir à nouveau sauvegarder la position du joueur en mode Manuel'
local firstspawn = 0 -- Ne pas toucher

--Notification joueur
function Notify(text)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(text)
    DrawNotification(false, true)
end

--Fonction sauvegarde automatique de la position du joueur
function Saver()
	--Boucle Thread d'envoie de la position toutes les x secondes vers le serveur pour effectuer la sauvegarde
	Citizen.CreateThread(function ()
		while true do
			if autoSave then
				--Durée entre chaque requêtes
				Citizen.Wait(timerofsave)
				--Récupération de la position x, y, z du joueur
				LastPosX, LastPosY, LastPosZ = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
				--Récupération de l'azimut du joueur
				local LastPosH = GetEntityHeading(GetPlayerPed(-1))
				--Envoi des données vers le serveur
				TriggerServerEvent("projectEZ:savelastpos", LastPosX , LastPosY , LastPosZ, LastPosH)
				if not origin then
					--Affichage d'un message confirmant la sauvegarde de la position du joueurs.
					Notify("Position Sauvegardée")
				end
			else
				Citizen.Wait(0)
				if IsControlJustPressed(1, Keys["."])  then
					--Récupération de la position x, y, z du joueur
					LastPosX, LastPosY, LastPosZ = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
					--Récupération de l'azimut du joueur
					local LastPosH = GetEntityHeading(GetPlayerPed(-1))
					--Envoi des données vers le serveur
					TriggerServerEvent("projectEZ:savelastpos", LastPosX , LastPosY , LastPosZ, LastPosH)
					if not origin then
						Notify("Position sauvegardée")
						Citizen.Wait(spamdelay)
					end
				end
			end	
		end
	end)
end

--Event permetant au serveur d'envoyez une notification au joueur
RegisterNetEvent('projectEZ:notify')
AddEventHandler('projectEZ:notify', function(alert)
    if not origin then
        Notify(alert)
    end
end)

--Event pour le spawn du joueur vers la dernière position connue
AddEventHandler("projectEZ:spawnlaspos", function(PosX, PosY, PosZ)
	SetEntityCoords(GetPlayerPed(-1), PosX, PosY, PosZ, 1, 0, 0, 1)
	if not origin then
		Notify("Vous voici à votre dernière position")
    end
	Saver()
end)

--Action lors du spawn du joueur
AddEventHandler('playerSpawned', function(spawn)
	--On verifie que c'est bien le premier spawn du joueur
	if firstspawn == 0 then
		TriggerServerEvent("projectEZ:SpawnPlayer")
		firstspawn = 1
	end
end)