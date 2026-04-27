-- Replace with your actual OpenRouter API key
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
        -- Standard OpenAI chat completion payload
        local payload = {
            model = MODEL,
            messages = {
                { role = "user", content = input }
            }
        }

        local postData = textutils.serializeJSON(payload)
        local headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. API_KEY
        }

        write("AI is thinking... ")
        local response, err = http.post(API_URL, postData, headers)

        -- clear the "thinking..." line
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
                print("Raw: " .. tostring(responseText))
            end
        else
            print("HTTP Request failed: " .. tostring(err))
        end
        print() -- Add an empty line for readability
    end
end