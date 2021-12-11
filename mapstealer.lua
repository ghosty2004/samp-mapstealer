script_author('Ghosty2004');

--[[ Modules ]]
local ev = require('samp.events');

--[[ Variables ]]
local mapstealer = false;
local objects = {};
local labels = {};
local count = 0;
local count_object_Id = {};

--[[ Main ]]
function main()
    repeat wait(0) until isSampAvailable()
    SCM("Loaded.");

    sampRegisterChatCommand("mapstealer", function()
        mapstealer = not mapstealer;
        if(mapstealer) then  
            SCM("Started.");
        else 
            local map = "new ghosty2004_map;";

            local objects_count = 0;
            local materials_count = 0;
            local materialstext_count = 0;

            local count = 0;
            local maps = {};

            for key, value in pairs(objects) do 
                count = count + 1;

                --[[ Objects ]]
                if(value[1]) then
                    for key_object, value_object in pairs(value[1]) do 
                        objects_count = objects_count + 1; 
                        table.insert(maps, string.format("%s", value_object));
                    end
                end
                --[[ Materials ]]
                if(value[2]) then
                    for key_material, value_material in pairs(value[2]) do 
                        materials_count = materials_count + 1; 
                        table.insert(maps, string.format("%s", value_material));
                    end
                end
                --[[ Materials Text ]]
                if(value[3]) then 
                    for key_materialtext, value_materialtext in pairs(value[3]) do 
                        materialstext_count = materialstext_count + 1; 
                        table.insert(maps, string.format("%s", value_materialtext));
                    end;
                end
            end

            for key, value in pairs(maps) do map = string.format("%s\n%s", map, value); end 

            for key, value in pairs(labels) do sampDestroy3dText(value); end 

            SCM(string.format("Saved: %d objects, %d materials and %d materials text.", objects_count, materials_count, materialstext_count));
            
            local header = "/* ======================== */\n/* Ghosty2004's map stealer */\n/* ======================== */";

            local ip, port = sampGetCurrentServerAddress();

            createDirectory("ghosty2004_mapstealer");
            local file = io.open(string.format("ghosty2004_mapstealer\\%s_%d.txt", ip, port), "w");
            file:write(string.format("\n%s\n\n%s", header, map));
            file:close();

            objects = {};
            labels = {};
        end 
    end)

    while true do 
        wait(0);
        if(mapstealer) then 
            local count = 0;
            for key, value in pairs(objects) do count = count + 1; end
            local positionX, positionY, positionZ = getCharCoordinates(PLAYER_PED);
            addOneOffSound(positionX, positionY, positionZ, 1058);
            info(string.format("Recording...~n~Stealed objects: ~y~~h~%d", count), 1);
        end 
    end 
end

function onExitScript(quitGame) 
    for key, value in pairs(labels) do sampDestroy3dText(value); end 
end 

--[[ Events ]]
function ev.onCreateObject(objectId, data)
    if(mapstealer) then
        local object_string = string.format("ghosty2004_map = CreateDynamicObject(%d, %f, %f, %f, %f, %f, %f, %d, %d, %d, %f, %f);", data.modelId, data.position.x, data.position.y, data.position.z, data.rotation.x, data.rotation.y, data.rotation.z, -1, -1, -1, 400, 400);
        if(not checkIfThisObjectSrcExists(object_string)) then
            count = count + 1;
            if(not objects[count]) then
                count_object_Id[count] = objectId;
                objects[count] = {};
                objects[count][1] = {};
                table.insert(objects[count][1], string.format("%s", object_string));
                labels[count] = sampCreate3dText(string.format("Object Info:\nID: %d | Model: %d", count, data.modelId), -1, data.position.x, data.position.y, data.position.z, data.drawDistance, true, -1, -1);
            end
        end
    end
end 

function ev.onSetObjectMaterial(objectId, data) 
    if(mapstealer) then
        local index = getIndexByObjectId(objectId);
        if(index ~= -1) then 
            if(objects[index]) then
                if(not objects[index][2]) then objects[index][2] = {}; end
                table.insert(objects[index][2], string.format("SetDynamicObjectMaterial(ghosty2004_map, %d, %d, \"%s\", \"%s\", %d);", data.materialId, data.modelId, data.libraryName, data.textureName, data.color));
            end
        end
    end
end 

function ev.onSetObjectMaterialText(objectId, data)
    if(mapstealer) then
        local index = getIndexByObjectId(objectId);
        if(index ~= -1) then 
            if(objects[index]) then
                if(not objects[index][3]) then objects[index][3] = {}; end
                table.insert(objects[index][3], string.format("%s", string.format("SetDynamicObjectMaterialText(ghosty2004_map, %d, \"%s\", %d, \"%s\", %d, %d, %d, %d, %d);", data.materialId, data.text, data.materialSize, data.fontName, data.fontSize, data.bold, data.fontColor, data.backGroundColor, data.align)));
            end
        end
    end
end

--[[ Functions ]]
function SCM(text)
    tag = '{FF5656}[Ghosty2004 Map Stealer]: ';
    sampAddChatMessage(tag .. text, -1);
end

function info(text, time) 
    printStringNow(string.format("~r~~h~[Ghosty2004 Map Stealer] ~g~~h~%s", text), time)
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

function getIndexByObjectId(objectId) 
    local index = -1;
    for key, value in pairs(count_object_Id) do 
        if(value == objectId) then index = key; end
    end 
    return index;
end 

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function serializeTable(val, name, skipnewlines, depth)
    skipnewlines = skipnewlines or false
    depth = depth or 0

    local tmp = string.rep(" ", depth)

    if name then tmp = tmp .. name .. " = " end

    if type(val) == "table" then
        tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

        for k, v in pairs(val) do
            tmp =  tmp .. serializeTable(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
        end

        tmp = tmp .. string.rep(" ", depth) .. "}"
    elseif type(val) == "number" then
        tmp = tmp .. tostring(val)
    elseif type(val) == "string" then
        tmp = tmp .. string.format("%q", val)
    elseif type(val) == "boolean" then
        tmp = tmp .. (val and "true" or "false")
    else
        tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
    end

    return tmp
end