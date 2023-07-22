script_author('deep');

--[[ Modules ]]
local ev = require('samp.events');

--[[ Variables ]]
local mapstealer = false;

local objects = {};
local count = 0;
local temp_stream_data = {};

local remove_objects = {};
local remove_objects_count = 0;
local temp_remove_building_data = {};
local temp_remove_building_count = 0;

--[[ Main ]]
function main()
    repeat wait(0) until isSampAvailable()
    SCM("Loaded.");

    sampRegisterChatCommand("mapstealer", function()
        mapstealer = not mapstealer;
        if(mapstealer) then  
            SCM("Started.");
        else 
            local map = "";

            local objects_count = 0;
            local materials_count = 0;
            local materialstext_count = 0;
            local remove_building_count = 0;

            local maps = {};

            table.insert(maps, "public OnFilterScriptInit()");
            table.insert(maps, "{");

            table.insert(maps, "    new ghosty2004_map;");
            for key, value in pairs(objects) do 
                --[[ Objects ]]
                if(value[1]) then
                    for key_object, value_object in pairs(value[1]) do 
                        objects_count = objects_count + 1; 
                        table.insert(maps, string.format("    %s", value_object));
                    end
                end
                --[[ Materials ]]
                if(value[2]) then
                    for key_material, value_material in pairs(value[2]) do 
                        materials_count = materials_count + 1; 
                        table.insert(maps, string.format("    %s", value_material));
                    end
                end
                --[[ Materials Text ]]
                if(value[3]) then 
                    for key_materialtext, value_materialtext in pairs(value[3]) do 
                        materialstext_count = materialstext_count + 1; 
                        table.insert(maps, string.format("    %s", value_materialtext));
                    end;
                end
            end

            table.insert(maps, "}");

            table.insert(maps, "\n");

            table.insert(maps, "public OnPlayerConnect(playerid)");
            table.insert(maps, "{");

            for key, value in pairs(remove_objects) do 
                table.insert(maps, string.format("    %s", value));
                remove_building_count = remove_building_count + 1;
            end

            table.insert(maps, "}");

            for key, value in pairs(maps) do map = string.format("%s\n%s", map, value); end 

            for key, value in pairs(temp_stream_data) do 
                if(value.label) then sampDestroy3dText(value.label); end 
            end 

            SCM(string.format("Saved: %d objects, %d remove buildings, %d materials and %d materials text.", objects_count, remove_building_count, materials_count, materialstext_count));
            
            local header = "/* ======================== */\n/* Ghosty2004's map stealer */\n/* ======================== */";

            local ip, port = sampGetCurrentServerAddress();

            createDirectory("deepproject_mapstealer");
            local file = io.open(string.format("deepproject_mapstealer\\%s_%d.txt", ip, port), "w");
            file:write(string.format("\n%s\n\n%s", header, map));
            file:close();

            objects = {};
            temp_stream_data = {};
        end 
    end)

    while true do 
        wait(0);
        if(copy) then 
            --[[ Remove Building ]]
            local pPositionX, pPositionY, pPositionZ = getCharCoordinates(PLAYER_PED);
            for key, value in pairs(temp_remove_building_data) do
                local distance = getDistanceBetweenCoords3d(pPositionX, pPositionY, pPositionZ, value.position.x, value.position.y, value.position.z)
                if(distance <= 400) then 
                    remove_object_string = string.format("RemoveBuildingForPlayer(playerid, %d, %f, %f, %f, %f);", value.modelId, value.position.x, value.position.y, value.position.z, value.radius)
                    if(not checkIfThisRemoveBuildingSrcExists(remove_object_string)) then 
                        table.insert(remove_objects, remove_object_string);
                    end
                end
            end

            local objects_count = 0;
            local materials_count = 0;
            local materialstext_count = 0;
            local remove_building_count = 0;

            for key, value in pairs(objects) do 
                if(value[1]) then for _ in pairs(value[1]) do objects_count = objects_count + 1; end  end 
                if(value[2]) then for _ in pairs(value[2]) do materials_count = materials_count + 1; end end
                if(value[3]) then for _ in pairs(value[3]) do materialstext_count = materialstext_count + 1; end end
            end

            for key, value in pairs(remove_objects) do remove_building_count = remove_building_count + 1; end;

            info(string.format("Recording...~n~~w~~h~Objects: ~y~~h~%d ~w~~h~| Remove Buildings: ~y~~h~%d ~n~~w~~h~Materials: (~y~~h~%d~w~ Textures | ~y~~h~%d~w~~h~ Texts)", objects_count, remove_building_count, materials_count, materialstext_count), 1);
        end 
    end 
end

function onExitScript(quitGame) 
    for key, value in pairs(temp_stream_data) do 
        if(value.label) then sampDestroy3dText(value.label); end 
    end 
end 

--[[ Events ]]
function ev.onRemoveBuilding(modelId, position, radius) 
    temp_remove_building_count = temp_remove_building_count + 1;
    temp_remove_building_data[temp_remove_building_count] = {
        modelId = modelId;
        position = position;
        radius = radius;
    }
end 

function ev.onDestroyObject(objectId)
    if(temp_stream_data[objectId]) then sampDestroy3dText(temp_stream_data[objectId].label); end
    temp_stream_data[objectId] = {};
end 

function ev.onCreateObject(objectId, data)
    if(copy) then
        local object_string = string.format("deep_map = CreateDynamicObject(%d, %f, %f, %f, %f, %f, %f, %d, %d, %d, %f, %f);", data.modelId, data.position.x, data.position.y, data.position.z, data.rotation.x, data.rotation.y, data.rotation.z, -1, -1, -1, 400, 400);
        if(not checkIfThisObjectSrcExists(object_string)) then
            count = count + 1; 
            if(not objects[count]) then
                objects[count] = {};
                objects[count][1] = {};
                table.insert(objects[count][1], object_string);
                local positionX, positionY, positionZ = getCharCoordinates(PLAYER_PED);
                addOneOffSound(positionX, positionY, positionZ, 1058);
            end
        end 
        temp_stream_data[objectId] = {
            index = thisObjectSrcKey(object_string);
            objectInfo = {
                model = data.modelId;
            },
            label = sampCreate3dText("", -1, data.position.x, data.position.y, data.position.z, data.drawDistance, true, -1, -1);
        }
        updateThisLabel(thisObjectSrcKey(object_string));
    end
end 

function ev.onSetObjectMaterial(objectId, data) 
    if(copy) then
        local index = temp_stream_data[objectId].index;
        if(index ~= -1 and index) then 
            if(objects[index]) then
                local material_string = string.format("SetDynamicObjectMaterial(deep_map, %d, %d, \"%s\", \"%s\", %d);", data.materialId, data.modelId, data.libraryName, data.textureName, data.color);
                if(not isMaterialExists(index, material_string)) then 
                    if(not objects[index][2]) then objects[index][2] = {}; end
                    table.insert(objects[index][2], material_string);
                    updateThisLabel(index);
                end
            end
        end
    end
end 

function ev.onSetObjectMaterialText(objectId, data)
    if(copy) then
        local index = temp_stream_data[objectId].index;
        if(index ~= -1 and index) then 
            if(objects[index]) then
                local materialtext_string = string.format("SetDynamicObjectMaterialText(deep_map, %d, \"%s\", %d, \"%s\", %d, %d, %d, %d, %d);", data.materialId, data.text, data.materialSize, data.fontName, data.fontSize, data.bold, data.fontColor, data.backGroundColor, data.align);
                if(not isMaterialTextExists(index, materialtext_string)) then
                    if(not objects[index][3]) then objects[index][3] = {}; end
                    table.insert(objects[index][3], materialtext_string);
                    updateThisLabel(index);
                end
            end
        end
    end
end

--[[ Functions ]]
function SCM(text)
    tag = '{FF5656}[deep Project Map Stealer]: ';
    sampAddChatMessage(tag .. text, -1);
end

function info(text, time) 
    printStringNow(string.format("~r~~h~[Ghosty2004 Map Stealer] ~g~~h~%s", text), time)
end 

function updateThisLabel(labelIndex)
    for key, value in pairs(temp_stream_data) do 
        if(value.index == labelIndex) then 
            sampSet3dTextString(value.label, string.format("Object Info:\nID: %s | Model: %s\nMaterials: %s | Materials Text: %s", value.index, value.objectInfo.model, getMaterialCount(value.index), getMaterialTextCount(value.index)));
        end 
    end
end 

function checkIfThisRemoveBuildingSrcExists(src) 
    local exists = false;
    for key, value in pairs(remove_objects) do 
        if(value == src) then exists = true; end
    end 
    return exists;
end 

function checkIfThisObjectSrcExists(src) 
    local exists = false;
    for key, value in pairs(objects) do 
        if(value[1]) then
            for key_object, value_object in pairs(value[1]) do 
                if(src == value_object) then exists = true; end
            end
        end
    end
    return exists;
end

function getMaterialCount(index) 
    local count = 0;
    for key, value in pairs(objects) do 
        if(value[2]) then
            if(key == index) then
                for _, value_material in pairs(value[2]) do count = count + 1; end
            end 
        end
    end 
    return count;
end 

function getMaterialTextCount(index) 
    local count = 0;
    for key, value in pairs(objects) do 
        if(value[3]) then
            if(key == index) then
                for _, value_material in pairs(value[3]) do count = count + 1; end
            end 
        end
    end 
    return count;
end 

function isMaterialExists(index, src)
    local exists = false;
    for key, value in pairs(objects) do 
        if(value[2]) then
            if(key == index) then
                for key_object, value_material in pairs(value[2]) do 
                    if(src == value_material) then exists = true; end
                end
            end
        end
    end
    return exists;
end 

function isMaterialTextExists(index, src)
    local exists = false;
    for key, value in pairs(objects) do 
        if(value[3]) then
            if(key == index) then
                for key_object, value_materialtext in pairs(value[3]) do 
                    if(src == value_materialtext) then exists = true; end
                end
            end
        end
    end
    return exists;
end

function thisObjectSrcKey(src)
    local key_value = -1;
    for key, value in pairs(objects) do 
        if(value[1]) then
            for _, value_object in pairs(value[1]) do 
                if(src == value_object) then key_value = key; end
            end 
        end 
    end 
    return key_value;
end
