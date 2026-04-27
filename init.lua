-- IMPORTANT: You MUST replace this with a real API key from openrouter.ai
local API_KEY = "sk-or-v1-YOUR_API_KEY_HERE"
local API_URL = "https://openrouter.ai/api/v1/chat/completions"
local MODEL = "meta-llama/llama-3-8b-instruct:free"

if not http then
    print("HTTP API is disabled in ComputerCraft settings.")
    return
end

print("--- AI Chat Interface ---")
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
            messages = {
                { role = "user", content = input }
            }
        }

        local postData = textutils.serializeJSON(payload)
        local headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. API_KEY,
            ["HTTP-Referer"] = "http://localhost", -- OpenRouter requires this
            ["X-Title"] = "ComputerCraftChat"      -- OpenRouter optional but recommended
        }

        write("AI is thinking... ")
        -- Capture the errorResponse as the 3rd variable
        local response, err, errorResponse = http.post(API_URL, postData, headers)

        local x, y = term.getCursorPos()
        term.setCursorPos(1, y)
        term.clearLine() 

        if response then
            local responseText = response.readAll()
            response.close()
            
            local result = textutils.unserializeJSON(responseText)
            if result and result.choices and result.choices[1] and result.choices[1].message then
                print("AI: " .. result.choices[1].message.content)
            else
                print("Error: Failed to parse API response.")
            end
        else
            print("HTTP Request failed: " .. tostring(err))
            -- If the API sends back a specific error reason (like Invalid Key), print it:
            if errorResponse then
                print("Server details: " .. tostring(errorResponse.readAll()))
                errorResponse.close()
            else
                print("Make sure you replaced the API_KEY with a real key from OpenRouter!")
            end
        end
        print()
    end
end