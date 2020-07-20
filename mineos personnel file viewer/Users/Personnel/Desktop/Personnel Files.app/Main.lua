-- Import libraries and such
local GUI = require("GUI")
local system = require("System")
local component = require("component")
local event = require("Event")
local image = require("Image")
local internet = require("Internet")
local text = require("text")
local split = require("split")
local json = require("json")

local modem = component.modem

local database = {}
local personnelServerPort = 11769
local personnelAddress = "25fe0566-d4ff-4db2-9851-575581eacd82"

local function getUsername(uuid)
  local string, errorname, reason = internet.request("https://api.mojang.com/user/profiles/" .. uuid .. "/names")

  local jsonDecodedString = json.decode(string)

  return jsonDecodedString[#jsonDecodedString].name
end

local function getUUID(username)
  local string, errorname, reason = internet.request("https://api.mojang.com/users/profiles/minecraft/" .. username)

  local decodedString = json.decode("[" .. string .. "]")

  if type(decodedString[1]) ~= "nil" then
    return decodedString[1].id
  else
    return nil
  end
end
---------------------------------------------------------------------------------

-- Get localization table dependent of current system language
local localization = system.getCurrentScriptLocalization()

-- Add a new window to MineOS workspace
local workspace, window, menu = system.addWindow(GUI.titledWindow(1, 1, 120, 40, localization.title, true))

-- Add single cell layout to window
local layout = window:addChild(GUI.layout(1, 1, window.width, window.height, 1, 2))

local topLayout = layout:addChild(GUI.layout(1, 1, window.width, window.height / 2, 2, 1))
--layout.showGrid = true
--topLayout.showGrid = true

topLayout.defaultRow = 1
topLayout:setAlignment(1, 1, GUI.ALIGNMENT_HORIZONTAL_LEFT, GUI.ALIGNMENT_VERTICAL_CENTER)
topLayout:setAlignment(2, 1, GUI.ALIGNMENT_HORIZONTAL_RIGHT, GUI.ALIGNMENT_VERTICAL_CENTER)
layout:setAlignment(1, 2, GUI.ALIGNMENT_HORIZONTAL_LEFT, GUI.ALIGNMENT_VERTICAL_CENTER)

topLayout:setMargin(1, 1, 2, 0)
topLayout:setMargin(2, 1, 2, 0)
layout:setMargin(1, 2, 2, 0)

-- Add nice gray text object to layout
local usernameText = topLayout:addChild(GUI.text(1, 1, 0x4B4B4B, localization.username .. localization.unknown))
local uuidText = topLayout:addChild(GUI.text(1, 1, 0x4B4B4B, localization.uuid .. localization.unknown))

layout.defaultRow = 2
local lastknownlocation =
  layout:addChild(GUI.text(1, 1, 0x4B4B4B, localization.lastknownlocation .. localization.unknown))
local position = layout:addChild(GUI.text(1, 1, 0x4B4B4B, localization.position .. localization.unknown))
local description = layout:addChild(GUI.text(1, 1, 0x4B4B4B, localization.description .. localization.unknown))

topLayout.defaultColumn = 2
topLayout:addChild(
  GUI.image(
    1,
    1,
    image.fromString(
      "2010292A00⠐292A00⠠293000⢕293000⡕293000⡧293000⡳293000⡕293000⡧293000⡫292A00⢀293000⡸293000⡪293000⡺283000⡸283000⣜283000⢜283000⠮283000⣪283000⢪283000⢪283000⢪283000⡪283000⡺283000⡜293000⡮293000⡺2B3000⡿293000⡳2B3000⡿293000⢕2B3000⣻2B3000⣟292A00⠈293000⡳292A00⠌292A00⢀293000⡕293000⡵2B3000⣯293000⡜293000⣎2B3000⣷292A00⡁293000⢇293000⢯2B3000⣽283000⢜283000⢎283000⢏283000⢎283000⢮283000⡪283000⡣283000⡣283000⡳283000⡹283000⣜2B3000⣯293000⢣293000⢳2B3000⢿2B3000⣻2B3000⣯293000⡜293000⡕293000⣕293000⠵293000⣕293000⢵293000⢱2B3000⣽293000⡳293000⡱293000⡕2B3000⡿293000⡜292A00⢀292A00⠄302A00⠢292A00⡀305B00⠠295B00⡐305B00⡠295B00⠢305B00⡀305B00⡂295B00⠄305B00⠄292A00⡂293000⢕2B3000⣽293000⢇2B3000⣟283000⢫283000⢺283000⡪293000⢎293000⢎293000⢇293000⢇292A00⡰305B00⠄295B00⡐305B00⡀305B00⢄295B00⠢305B00⠐305B00⡀305C00⠂2A5B00⢊305B00⠢2A5B00⡑2A6000⢕2A6000⢜2A5B00⢌2A6000⢎2A5B00⢪2A6000⢸2A5B00⠨2A6000⡊305B00⠄305B00⢂292A00⡰295B00⠂293000⢇283000⢏283000⢧283000⡫293000⡳2B3000⢿292A00⡠305B00⠄619800⢰66C300⣖61C300⣶66BE00⣦61C300⣶66C300⣶66C300⣲66C300⣶8DC300⣶7EC300⣶7EC300⣶66C300⣶66C300⡶66C300⣶66C300⣶66C300⣶8DC300⡶61C300⣶66C300⣶61C300⣶61BE00⣆61BE00⣔619300⢄619300⠢306100⡇295C00⡂295B00⠄302A00⢐292A00⡢305B00⢀305C00⠨305B00⠄66C300⢸97C300⡺92C300⣕93C300⢜97C300⣞97C300⣞BDC300⡾98C300⢽98C300⣺98C300⣟98C300⣷98C300⢿98C300⣝93C300⡮BDC300⣳98C300⡺98C300⡽98C300⡮97C300⣞BDC300⣾92C300⢕92C200⠢929800⠜92BE00⡌2A9200⡇2A5B00⡸305B00⡀305B00⢂619800⣲61BD00⣶61BE00⡦66BD00⣾92BE00⢮97C300⣻92C300⡺93C300⣕92C200⠪92C300⡵92C300⣝92C300⢮92C300⣺92C300⢽92C300⣺92C300⢵929800⡫92C300⡪929800⡢92BD00⠈92C300⣳93C300⣫93C300⢺97C300⡾92BD00⠐92BD00⠈92BD00⡀929300⢐619300⠠619200⣶619300⠄619200⣲92BE00⣺92C300⡪97BE00⣇97BE00⢗97C300⣽97C300⣾98C300⡪93C300⡪92BE00⣗92C300⡯929800⣞92BE00⡵97C300⣳92C300⢯97BE00⣺97BE00⣳92BD00⠂92BD00⠈929800⢕92BE00⢕92C300⣽97C300⣾93C300⢜93C300⢕929800⢎929800⢆929300⢇929800⢇929300⢊929300⠌929300⡐929300⠠97C300⡳97C300⣝93C300⢕92C300⣷C3D700⢰C8FF00⣶C9D700⣶C8D700⣶62C400⡇629300⠈559300⠁619300⣟929300⣯93C300⢅92BE00⢮97BE00⡪97C300⣗93C300⢮93C300⢢92C300⣳629300⡏559300⠁559300⠉629300⠈81D700⢰C8D700⣶C9D700⣶C8D700⣶92C900⡧92C300⡳92BE00⣕92C300⢗97C300⢯97C300⣳BDC300⣻98C300⢕C8D700⢹FED700⣟D7D700⠀D7D700⠀62C400⡇626200⠀556200⣷556200⣳7E9300⢝92BE00⢮92C300⡳92BE00⡹97C300⣺92C300⣞93C300⠇97C300⢯559300⡃556200⣟626200⠀626200⠀AAD700⢸D7D700⠀FED700⣟D7D700⠀98C900⡂929800⣪929800⡳92BE00⣕929300⢁8D9300⠂929300⠌92BD00⠁93C900⠈92F300⢙BDC900⡹93C900⠉92AA00⡳7FC300⡄7EC300⡢7EBE00⣾619200⡏619200⠌609200⣻619200⡉619200⡉619200⠩619200⠩619300⠁7EC300⠐7EC300⡔92C300⡽7FC300⢔92C900⠩92C900⠉92C900⠉92C900⠉61C300⠁619200⡫619200⡻619200⡹8D9200⣗8D9200⣯8D9300⠂8D9200⣻92BE00⡪92BE00⡣97BE00⡫92BE00⡎97C300⡯97BE00⣺93C300⡎92C300⢯619200⡇608D00⣷5B6100⡯606100⣳606100⡽5B6100⣞608D00⡷608D00⡽8DC300⢸93C300⡪92C300⣫93C300⡪92C300⡁92BD00⠂92BD00⠄92BD00⠁619200⡯619100⠌619200⡪618D00⡣8D9200⡇669200⣻619200⢿669200⡿8D9200⢯8D9300⠈8D9200⣝8D9300⠈619200⡟609200⡿619200⡝5C9300⠁5C8D00⡑608D00⢿608D00⣽608D00⡷5C8D00⡰5C8D00⢐5B8D00⣯5C8D00⡢619200⢋619200⢫619200⢫619300⠁619200⢿8D9200⢝669200⡿8D9200⢮618D00⢝609200⡽619200⢜609200⣽619200⣗619200⢯619200⢿669200⡽8D9200⢵669200⢿619200⡿8D9200⣜618D00⢕608D00⢯5C8D00⡘608D00⣽608D00⡾5C8D00⠢608D00⡷5C8D00⢕608800⢽608D00⢽5C8D00⢌5B8D00⣞608D00⡷608D00⣯608D00⢷608D00⢷619200⣻619200⣺619200⡽619200⡯619200⡇619200⡇618D00⡇619200⡧608D00⣟608D00⡽608D00⣫608D00⢯608D00⢯608D00⡫608D00⡯608D00⣫608D00⣾619200⢪619200⢪609200⣷618D00⢱619200⢱619200⢸619200⢢608D00⣻608D00⣯608D00⡷618D00⢢619200⢣619200⡪619200⡪619200⡪619200⡪609200⡿619200⣏619200⢝609200⡿608D00⣯618D00⢪618D00⠨606100⣗606100⣯608D00⢯5B6100⡯606100⣗606100⣯5B8D00⣻606100⡺608D00⣾618D00⢨618D00⢊618D00⢎619200⢜618D00⢌619200⢎618D00⢜618D00⢐619200⢑609200⣟618D00⡢619200⢱619200⢸619200⢸619200⢪619200⢪619200⢪619200⢪619200⢪618D00⢑609200⣯608D00⣟618D00⠅"
    )
  )
)

-- Customize MineOS menu for this application by your will
local contextMenu = menu:addContextMenuItem("Entry")

contextMenu:addItem(localization.addentrymenu).onTouch = function()
  modem.send(personnelAddress, personnelServerPort, "get_database")
  local popupWorkspace, popupWindow, popupMenu =
    system.addWindow(GUI.titledWindow(1, 1, 32, 29, localization.addentrytitle, true))

  local popupLayout = popupWindow:addChild(GUI.layout(1, 1, popupWindow.width, popupWindow.height, 1, 1))

  local popupInputName =
    popupLayout:addChild(
    GUI.input(1, 1, 30, 3, 0xEEEEEE, 0x555555, 0x999999, 0xFFFFFF, 0x2D2D2D, "", localization.addentryinputname)
  )

  local popupInputLastKnownLocation =
    popupLayout:addChild(
    GUI.input(
      1,
      1,
      30,
      3,
      0xEEEEEE,
      0x555555,
      0x999999,
      0xFFFFFF,
      0x2D2D2D,
      "",
      localization.addentryinputlastknownlocation
    )
  )

  local popupInputPositon =
    popupLayout:addChild(
    GUI.input(1, 1, 30, 3, 0xEEEEEE, 0x555555, 0x999999, 0xFFFFFF, 0x2D2D2D, "", localization.addentryinputposition)
  )

  local popupInputDescription =
    popupLayout:addChild(
    GUI.input(1, 1, 30, 3, 0xEEEEEE, 0x555555, 0x999999, 0xFFFFFF, 0x2D2D2D, "", localization.addentryinputdescription)
  )

  local popupInputUsername =
    popupLayout:addChild(
    GUI.input(1, 1, 30, 3, 0xEEEEEE, 0x555555, 0x999999, 0xFFFFFF, 0x2D2D2D, "", localization.addentryinputusername)
  )

  local popupInputPassword =
    popupLayout:addChild(
    GUI.input(1, 1, 30, 3, 0xEEEEEE, 0x555555, 0x999999, 0xFFFFFF, 0x2D2D2D, "", localization.addentryinputpassword)
  )

  local regularButton =
    popupLayout:addChild(GUI.button(1, 1, 30, 3, 0xFFFFFF, 0x555555, 0x880000, 0xFFFFFF, localization.addentrybutton))
  regularButton.onTouch = function()
    modem.send(
      personnelAddress,
      personnelServerPort,
      "add_entry",
      popupInputUsername.text,
      popupInputPassword.text,
      tostring(getUUID(popupInputName.text)),
      popupInputLastKnownLocation.text,
      popupInputPositon.text,
      popupInputDescription.text
    )

    modem.send(personnelAddress, personnelServerPort, "get_database")
  end
end

contextMenu:addItem(localization.loadfilemenu).onTouch = function()
  modem.send(personnelAddress, personnelServerPort, "get_database")
  local popupWorkspace, popupWindow, popupMenu =
    system.addWindow(GUI.titledWindow(1, 1, 32, 6, localization.loadfiletitle, true))
  local popupInput =
    popupWindow:addChild(
    GUI.input(2, 3, 30, 3, 0xEEEEEE, 0x555555, 0x999999, 0xFFFFFF, 0x2D2D2D, "", localization.loadfile)
  )
  popupInput.onInputFinished = function()
    modem.send(personnelAddress, personnelServerPort, "get_database")
    --GUI.alert(tostring(getUUID(popupInput.text)))

    local getUUIDOutput = getUUID(popupInput.text)

    if type(getUUIDOutput) ~= "nil" then
      usernameText.text = localization.username .. popupInput.text
      uuidText.text = localization.uuid .. getUUIDOutput
      lastknownlocation.text = localization.lastknownlocation .. database.data[getUUIDOutput].lastknownlocation
      position.text = localization.position .. database.data[getUUIDOutput].position
      description.text = localization.description .. database.data[getUUIDOutput].description
    end
    popupWindow:remove()
  end
end

-- Create callback function with resizing rules when window changes its' size
window.onResize = function(newWidth, newHeight)
  window.backgroundPanel.width, window.backgroundPanel.height = newWidth, newHeight
  layout.width, layout.height = newWidth, newHeight
  topLayout.width, topLayout.height = newWidth, newHeight / 2

  window.titlePanel.width = newWidth
end

---------------------------------------------------------------------------------

modem.open(personnelServerPort)

local modemHandler =
  event.addHandler(
  function(
    eventType,
    _,
    sendingAddress,
    port,
    distance,
    userAccepted,
    passAccepted,
    requestCompleted,
    requestError,
    requestData)
    if eventType == "modem_message" and port == personnelServerPort then
      if userAccepted == false then
        GUI.alert(localization.usernotexist)
      elseif (userAccepted == true) and (passAccepted == false) then
        GUI.alert(localization.passwordincorrect)
      elseif (userAccepted == true) and (passAccepted == true) then
        if requestData ~= "" then
          database = text.deserialize(requestData)
        end
      end
    end
  end
)

modem.send(personnelAddress, personnelServerPort, "get_database")

--usernameText.text = localization.username .. getUsername("e1a2192c87204eb2854215d2e7632a72")
--uuidText.text = localization.uuid .. getUUID("PoltixeTheDerg")

-- Draw changes on screen after customizing your window
workspace:draw()
