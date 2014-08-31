FLAG = false
MOVEFLAG = true
DONE = false
BANK = false

--Event handler function
function NeatFreak_OnEvent(self, event, ...)
	if event == "ADDON_LOADED" and ... == "NeatFreak" then
		updateInventory()
	elseif event == "BANKFRAME_OPENED" then
		BANK = true
		print("OPEN")
	elseif event == "BANKFRAME_CLOSED" then
		BANK = false
	elseif event == "ITEM_LOCKED" then
		if MOVEFLAG then
			bagId = select(1,...); slotId = select(2,...);
			blockSelect(bagId, slotId);
		end
	elseif event == "BAG_UPDATE" then
		containerId = select(1,...);
		moveMult(containerId);
	end
end

function updateInventory()
	--Table of items in containers
	if not itemTable then
		itemTable = {}
	end
	tempStart, tempEnd = isBankOpen()
	--print(tempStart, ",", tempEnd)
	for bag = tempStart,tempEnd do
		for slot = 1,GetContainerNumSlots(bag) do
			itemID = GetContainerItemID(bag,slot)
			if itemID then
				texture, count, locked, quality, readable, lootable, link = GetContainerItemInfo(bag,slot)
				if not itemTable[itemID] then
					itemTable[itemID] = {
						count = count,
						link = link,
						bag,
						slot,
					}
				else
					itemTable[itemID].count = itemTable[itemID].count + count
					table.insert(itemTable[itemID], bag)
					table.insert(itemTable[itemID], slot)
				end
			end
		end
	end
	
end

function isBankOpen()
	if BANK then
		tempStart = -1
		tempEnd = NUM_BAG_SLOTS + NUM_BANKBAGSLOTS
	else
		tempStart = 0
		tempEnd  = NUM_BAG_SLOTS
	end
	return tempStart, tempEnd
end

--Select a block of items: creates block from first item selected and last item selected.
--After selection is done, picks up first item of block to indicate it's ready to move
function blockSelect(bagId, slotId)
	if not FLAG then
		--To implement: Start always from min(slotEnd, slotStart)
		blockStartBag = bagId
		blockStartSlot = slotId
		FLAG = not FLAG
		--itemData used for finding move location
		itemType, itemData = GetCursorInfo()
		print("Starts: ", blockStartBag, blockStartSlot)
		--set item back to its slot
		PickupContainerItem(blockStartBag,blockStartSlot)
	else
		blockEndBag = bagId
		blockEndSlot = slotId
		FLAG = not FLAG
		MOVEFLAG = false
		print("Ends: ", blockEndBag, blockEndSlot)
		--drop last selection
		PickupContainerItem(blockEndBag,blockEndSlot)
		--pick up first selection
		PickupContainerItem(blockStartBag,blockStartSlot)
	end	
end	

--move the selected block to the desired location
function moveMult(containerId)
	if MOVEFLAG or DONE then
		return
	end
	--print(containerId);
	targetBag, targetSlot = findItemSlot()
	bag = blockStartBag; slot = blockStartSlot;
	while true do
		--go to next item in block
		slot = slot + 1
		targetSlot = targetSlot + 1
		--if past the last slot of the bag, go to first slot of next bag
		if slot  == GetContainerNumSlots(bag)+1  then
			bag = bag + 1
			slot = 1
		end
		if targetSlot == GetContainerNumSlots(targetBag)+1 then
			targetBag = targetBag + 1
			targetSlot = 1
		end
		print("(", bag, ",", slot, "):(", targetBag, ",", targetSlot, ")" )
		PickupContainerItem(bag, slot)
		PickupContainerItem(targetBag, targetSlot)
		if bag == blockEndBag and slot == blockEndSlot then
			DONE = true
			break
		end
	end
end

function findItemSlot()
	print("Searching...")
	tempStart, tempEnd = isBankOpen()
	for bag = tempStart,tempEnd do
		for slot = 1,GetContainerNumSlots(bag) do
			if GetContainerItemID(bag,slot) == itemData then
				--steps of 2
				foundFlag = 0
				for i = 1, #itemTable[itemData], 2 do
					if foundFlag == 1 then
						--ignore the rest of the matching
					elseif ((bag == itemTable[itemData][i]) and (slot == itemTable[itemData][i+1])) then
						--continue statement doesn't exist in Lua. Implementing a pseudo-continue with flag
						print("Found match")
						foundFlag = 1
					end
				end
				--if the current item had no match to table, it has moved
				if foundFlag == 0 then
					print("Move to: ", bag, ",", slot)
					return bag, slot
				end
			end
		end
	end
end

