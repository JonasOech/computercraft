local OLLAMA_URL = "http://your-ollama-host:11434/api/generate"
local MODEL = "llama3" -- replace with your cloud model

if not http then
    print("HTTP API is disabled in ComputerCraft settings.")
    return
end

print("--- Ollama Chat Interface ---")
print("Target model: " .. MODEL)
print("Type 'exit' to quit.")
print("-----------------------------")

while true do
    write("You: ")
    local input = read()
    
    if string.lower(input) == "exit" then
        print("Goodbye!")
        break
    end

    if input ~= "" then
        local payload = {
            model = MODEL,
            prompt = input,
            stream = false
        }

        local postData = textutils.serializeJSON(payload)
        local headers = {
            ["Content-Type"] = "application/json"
        }

        write("Ollama is thinking... ")
        local response, err = http.post(OLLAMA_URL, postData, headers)

        -- clear the "thinking..." line
        local x, y = term.getCursorPos()
        term.setCursorPos(1, y)
        term.clearLine() 

        if response then
            local responseText = response.readAll()
            response.close()
            
            local result = textutils.unserializeJSON(responseText)
            if result and result.response then
                print("Ollama: " .. result.response)
            else
                print("Error: Failed to parse API response.")
                print("Raw: " .. tostring(responseText))
            end
        else
            print("HTTP Request failed: " .. tostring(err))
        end
        print() -- Add an empty line for readability
    end
end