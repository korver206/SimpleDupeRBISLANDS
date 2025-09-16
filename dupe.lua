-- Islands Item Duplicator Script for Vega X
-- Scans remotes and functions, adds items to backpack by ID and amount
-- Items stack infinitely in one slot
-- UI on bottom left with item browser, G to toggle, Shift+G to exit

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Variables
local remotes = {}
local funcs = {}
local uiVisible = false
local exitScript = false
local screenGui
local frame
local idTextBox
local amountTextBox
local addButton
local categoryButtons = {}
local itemFrame
local currentCategory = nil
local items = {}

-- Parse item data
local itemData = [[
2	Aquamarine Sword	COMBAT
3	Ancient Longbow	COMBAT
6	Cactus Spike	COMBAT
8	Cutlass	COMBAT
9	Diamond Great Sword	COMBAT
10	Diamond War Hammer	COMBAT
11	Formula 86	MISC
12	Gilded Steel Hammer	COMBAT
13	Staff of Godzilla	COMBAT
15	Iron War Axe	COMBAT
16	Rageblade	COMBAT
19	Spellbook	COMBAT
21	Lightning Scepter	COMBAT
22	Tidal Spellbook	COMBAT
24	Azarathian Longbow	COMBAT
27	Aquamarine Shard	MINERALS
28	Buffalkor Crystal	MINERALS
31	Electrite	MINERALS
32	Copper Bolt	INDUSTRIAL
33	Copper Ingot	INDUSTRIAL
35	Copper Plate	INDUSTRIAL
36	Copper Rod	INDUSTRIAL
37	Crystallized Aquamarine	MINERALS
38	Crystallized Gold	MINERALS
39	Crystallized Iron	MINERALS
40	Diamond	MINERALS
41	Enchanted Diamond	MINERALS
42	Gearbox	INDUSTRIAL
43	Gilded Steel Rod	INDUSTRIAL
44	Gold Ingot	INDUSTRIAL
46	Iron Ingot	INDUSTRIAL
48	Red Bronze Ingot	INDUSTRIAL
49	Steel Bolt	INDUSTRIAL
50	Steel Ingot	INDUSTRIAL
51	Steel Plate	INDUSTRIAL
52	Steel Rod	INDUSTRIAL
84	Fish Banner	DECOR
85	Fish Festival Trophy 2021	DECOR
94	Godzilla Trophy	DECOR
101	Kong Trophy	DECOR
138	PVP Alpha Trophy	DECOR
139	Roblox Battles Trophy	DECOR
144	Snow Globe	DECOR
147	Tall Snowman	DECOR
148	The Witches Trophy	DECOR
149	Tidal Aquarium	DECOR
155	Wide Snowman	DECOR
157	Wreath	DECOR
158	Desert Portal	MISC
159	Wizard Portal	MISC
160	Slime Portal	MISC
161	Buffalkor Portal	MISC
162	Diamond Mines Portal	MISC
163	And Gate	INDUSTRIAL
165	Coal Generator	INDUSTRIAL
166	Combiner	INDUSTRIAL
167	Electrical Workbench	TOOLS
168	Firework Launcher	INDUSTRIAL
170	Or Gate	INDUSTRIAL
171	Conveyor Sensor	INDUSTRIAL
172	Solar Panel	INDUSTRIAL
173	Spawn Block	BLOCKS
174	Splitter Conveyor	INDUSTRIAL
175	Splitter	INDUSTRIAL
176	Steam Generator	INDUSTRIAL
177	Switch	INDUSTRIAL
179	Totem Disabler	INDUSTRIAL
180	Xor Gate	INDUSTRIAL
187	Christmas Shovel	TOOLS
191	Diamond Axe	TOOLS
192	Diamond Pickaxe	TOOLS
193	Diamond Sickle	TOOLS
194	Basic Fertilizer	INDUSTRIAL
198	Gilded Steel Axe	TOOLS
199	Gilded Steel Pickaxe	TOOLS
200	Gilded Steel Sickle	TOOLS
205	Iron Fishing Rod	TOOLS
207	Leaf Clippers	TOOLS
220	Wire Tool	TOOLS
225	Workbench Tier 3	TOOLS
230	Red Berry Seeds	CROPS
249	Pumpkin Seeds	CROPS
251	Radish Seeds	CROPS
253	Starfruit Seeds	CROPS
257	Watermelon Seeds	CROPS
266	Carrot Cake	FOOD
269	Chocolate Bar	FOOD
270	Deviled Eggs	FOOD
275	Jam Sandwich	FOOD
279	Lollipop	FOOD
283	Orange Candy	FOOD
286	Potato Salad	FOOD
287	Starfruit Cake	FOOD
289	Tomato Soup	FOOD
294	Bolt Factory Mold	INDUSTRIAL
295	Campfire	INDUSTRIAL
298	Conveyor Belt	INDUSTRIAL
299	Drill	INDUSTRIAL
301	Industrial Chest	INDUSTRIAL
302	Food Processor	INDUSTRIAL
303	Industrial Oven	INDUSTRIAL
304	Industrial Sawmill	INDUSTRIAL
305	Industrial Smelter	INDUSTRIAL
306	Industrial Stonecutter	INDUSTRIAL
307	Industrial Washing Station	INDUSTRIAL
308	Copper Press	INDUSTRIAL
309	Input/Output Chest	INDUSTRIAL
311	Left Conveyor Belt	INDUSTRIAL
312	Medium Chest	INDUSTRIAL
320	Randomizer	INDUSTRIAL
321	Industrial Lumbermill	INDUSTRIAL
322	Industrial Milker	INDUSTRIAL
323	Wool Vacuum	INDUSTRIAL
324	Red Bronze Refinery	INDUSTRIAL
326	Right Conveyor Belt	INDUSTRIAL
327	Rod Factory Mold	INDUSTRIAL
328	Sawmill	INDUSTRIAL
329	Small Chest	INDUSTRIAL
330	Small Furnace	INDUSTRIAL
331	Basic Sprinkler	INDUSTRIAL
332	Steel Mill	INDUSTRIAL
333	Steel Press	INDUSTRIAL
334	Stonecutter	INDUSTRIAL
336	Vending Machine	INDUSTRIAL
337	Washing Station	INDUSTRIAL
339	Water Catcher	INDUSTRIAL
343	Animal Well-Being Kit	ANIMALS
349	Chicken Spawn Egg Tier 2	ANIMALS
350	Chicken Spawn Egg Tier 3	ANIMALS
354	Cow Spawn Egg Tier 2	ANIMALS
355	Cow Spawn Egg Tier 3	ANIMALS
364	Pig Spawn Egg Tier 2	ANIMALS
365	Pig Spawn Egg Tier 3	ANIMALS
369	Sheep Spawn Egg Tier 2	ANIMALS
370	Sheep Spawn Egg Tier 3	ANIMALS
401	Diamond Block	BLOCKS
405	Gold Block	BLOCKS
416	Ice	BLOCKS
430	Mushroom Block	BLOCKS
455	Sea Lantern	BLOCKS
475	Regen Potion	COMBAT
476	Strength Potion	COMBAT
488	Christmas Present 2020	MISC
489	Legacy Food Processor	MISC
492	Portal Crystal	MISC
505	Apple Tree Sapling	CROPS
511	Lemon Tree Sapling	CROPS
516	Orange Tree Sapling	CROPS
517	Palm Tree Sapling	LUMBER
520	Ancient Slime String	INDUSTRIAL
521	Blue Sticky Gear	INDUSTRIAL
523	Buffalkor Portal Shard	MISC
524	Desert Portal Shard	MISC
525	Diamond Mines Portal Shard	MISC
526	Frosty Slime Ball	MISC
527	Gold Skorp Claw	MISC
528	Gold Skorp Scale	MISC
529	Green Sticky Gear	INDUSTRIAL
531	Iron Skorp Scale	MISC
532	Pearl	MINERALS
533	Pink Sticky Gear	INDUSTRIAL
535	Propeller	INDUSTRIAL
536	Ruby Skorp Scale	MISC
537	Ruby Skorp Stinger	MISC
538	Slime Portal Shard	MISC
539	Wizard Portal Shard	MISC
540	Islands First Anniversary Cake	DECOR
541	Blue Firefly Jar	ANIMALS
542	Green Firefly Jar	ANIMALS
543	Purple Firefly Jar	ANIMALS
544	Red Firefly Jar	ANIMALS
549	Kong's Axe	COMBAT
582	Fertile White Rose	FLOWERS
583	Fertile White Daffodil	FLOWERS
584	White Daffodil	FLOWERS
585	White Daisy	FLOWERS
586	Fertile White Daisy	FLOWERS
587	Fertile White Hibiscus	FLOWERS
588	White Hibiscus	FLOWERS
590	Fertile Red Daisy	FLOWERS
591	Fertile Red Hyacinth	FLOWERS
592	Red Hyacinth	FLOWERS
593	Red Lily	FLOWERS
594	Fertile Red Lily	FLOWERS
596	Fertile Red Rose	FLOWERS
597	Fertile Red Daffodil	FLOWERS
599	Orange Hibiscus	FLOWERS
600	Fertile Orange Hibiscus	FLOWERS
601	Fertile Orange Daffodil	FLOWERS
602	Orange Daffodil	FLOWERS
603	Orange Hyacinth	FLOWERS
604	Fertile Orange Hyacinth	FLOWERS
606	Fertile Yellow Daffodil	FLOWERS
608	Fertile Yellow Daisy	FLOWERS
609	Fertile Yellow Lily	FLOWERS
610	Yellow Lily	FLOWERS
612	Fertile Yellow Hyacinth	FLOWERS
613	Yellow Daffodil	FLOWERS
615	Dark Green Daffodil	FLOWERS
616	Fertile Dark Green Daffodil	FLOWERS
617	Dark Green Daisy	FLOWERS
618	Fertile Dark Green Daisy	FLOWERS
619	Fertile Dark Green Lily	FLOWERS
620	Dark Green Lily	FLOWERS
621	Light Green Daffodil	FLOWERS
622	Fertile Light Green Daffodil	FLOWERS
624	Fertile Light Green Hibiscus	FLOWERS
625	Light Green Daisy	FLOWERS
626	Fertile Light Green Daisy	FLOWERS
627	Light Green Hyacinth	FLOWERS
628	Fertile Light Green Hyacinth	FLOWERS
629	Cyan Daisy	FLOWERS
630	Fertile Cyan Daisy	FLOWERS
631	Cyan Hyacinth	FLOWERS
632	Fertile Cyan Hyacinth	FLOWERS
633	Cyan Lily	FLOWERS
634	Fertile Cyan Lily	FLOWERS
635	Blue Hibiscus	FLOWERS
636	Fertile Blue Hibiscus	FLOWERS
637	Fertile Blue Rose	FLOWERS
639	Blue Lily	FLOWERS
640	Fertile Blue Lily	FLOWERS
641	Blue Hyacinth	FLOWERS
642	Fertile Blue Hyacinth	FLOWERS
643	Purple Hibiscus	FLOWERS
644	Fertile Purple Hibiscus	FLOWERS
645	Purple Rose	FLOWERS
646	Fertile Purple Rose	FLOWERS
647	Black Hibiscus	FLOWERS
648	Fertile Black Hibiscus	FLOWERS
649	Black Lily	FLOWERS
650	Fertile Black Lily	FLOWERS
719	Shipwreck Podium	DECOR
720	Ruby	MINERALS
721	Ruby Staff	COMBAT
722	Ruby Block	BLOCKS
737	Lunar Banner	DECOR
756	Industrial Polishing Station	INDUSTRIAL
757	Polishing Station	INDUSTRIAL
787	Pink Rabbit	ANIMALS
789	Jack 0 Lantern	DECOR
794	Pumpkin Totem	TOTEMS
802	Spirit Sapling	LUMBER
828	The Captain's Rapier	COMBAT
829	Crystallized Obsidian	MINERALS
832	Pirate Cannon	DECOR
833	Pirate Barrel	DECOR
834	Pirate Chair	DECOR
835	Pirate Chandelier	DECOR
836	Pirate Lamp	DECOR
837	Pirate Ship Wheel	DECOR
838	Pirate Ship	DECOR
839	Pirate Table	DECOR
840	Obsidian	BLOCKS
841	Bone Block	BLOCKS
842	Opened Treasure Chest	INDUSTRIAL
843	Treasure Chest	MISC
844	Obsidian Hilt	COMBAT
845	Obsidian Greatsword	COMBAT
860	Green Slime Block	BLOCKS
861	Blue Slime Block	BLOCKS
862	Pink Slime Block	BLOCKS
863	Pirate Globe	DECOR
864	Desert Chest	INDUSTRIAL
865	Desert Furnace	INDUSTRIAL
870	Cletus Lucky Sickle	TOOLS
871	Cletus Lucky Watering Can	TOOLS
872	Chili Pepper Seeds	CROPS
874	Cletus Lucky Plow	TOOLS
875	Scarecrow Trophy	DECOR
876	Cletus Scarecrow	DECOR
877	Oil Barrel	INDUSTRIAL
878	Petroleum Barrel	INDUSTRIAL
879	Oil Refinery	INDUSTRIAL
880	Pumpjack	INDUSTRIAL
881	Pipe	INDUSTRIAL
882	Pipe Junction	INDUSTRIAL
883	Tier 2 Right Conveyor Belt	INDUSTRIAL
884	Tier 2 Left Conveyor Belt	INDUSTRIAL
885	Tier 2 Conveyor Ramp Up	INDUSTRIAL
887	Petroleum Tank	INDUSTRIAL
888	Oil Tank	INDUSTRIAL
889	Tier 2 Crate Packer	INDUSTRIAL
890	Tree Fruit Shaker	INDUSTRIAL
891	Sapling Automatic Planter	INDUSTRIAL
892	Petroleum Petrifier	INDUSTRIAL
893	Fuel Barrel Extractor	INDUSTRIAL
894	Fuel Barrel Filler	INDUSTRIAL
895	Merger	INDUSTRIAL
896	Workbench Tier 4	TOOLS
897	Automated Trough	INDUSTRIAL
898	Petrified Petroleum	INDUSTRIAL
912	DV Trophy	DECOR
913	Tier 2 Vending Machine	INDUSTRIAL
914	Filter Conveyor	INDUSTRIAL
915	Pallet Packer	INDUSTRIAL
952	Roasted Honey Carrot	FOOD
961	The Dragonslayer	COMBAT
962	Opal Pickaxe	TOOLS
963	Opal Axe	TOOLS
964	Opal Pickaxe Hilt	TOOLS
965	Opal Axe Hilt	TOOLS
966	Opal Sword Hilt	COMBAT
967	Magma Block	BLOCKS
968	Opal	MINERALS
969	Infernal Dragon Egg	MISC
989	Obsidian Totem	TOTEMS
993	Conveyor Ramp Down	INDUSTRIAL
994	Blackberry Seeds	CROPS
995	Blueberry Seeds	CROPS
998	Red Berry Bush Totem	TOTEMS
999	Blackberry Bush Totem	TOTEMS
1000	Blueberry Bush Totem	TOTEMS
1003	Large Chest	INDUSTRIAL
1004	Tier 2 Input/Output Chest	INDUSTRIAL
1005	Timed Input-Output Chest	INDUSTRIAL
1006	Industrial Flower Picker	INDUSTRIAL
1007	Industrial Merchant Teleseller	INDUSTRIAL
1010	Cauldron 2021	MISC
1011	Pumpkin Cat	DECOR
1012	Cobweb	DECOR
1013	Ghost Lantern	DECOR
1014	Halloween Lantern	DECOR
1015	Gravestone 2021	DECOR
1018	The Halloween Trophy	DECOR
1019	Pumpkin Bed	DECOR
1021	Pumpkin Hammer	COMBAT
1022	Candy Basket 2021	DECOR
1023	Spooky Pumpkin	DECOR
1028	Rice Seeds	CROPS
1030	Truffle Avocado Toast	FOOD
1031	Truffle Pizza	FOOD
1032	Dragon Roll	FOOD
1033	Philadelphia Roll	FOOD
1035	Tai Nigiri	FOOD
1036	Tuna Roll	FOOD
1049	Sap Boiler	INDUSTRIAL
1050	Syrup Bottler	INDUSTRIAL
1055	Maple Shield	COMBAT
1056	Antler Shield	COMBAT
1057	Antler Hammer	COMBAT
1069	Fhanhorns Flower	FOOD
1070	Fhanhorns Pancakes	FOOD
1073	Turkey Spawn Egg Tier 2	ANIMALS
1074	Turkey Spawn Egg Tier 3	ANIMALS
1083	Light Blue Coral Block	BLOCKS
1084	Pink Coral Block	BLOCKS
1085	Blue Coral Block	BLOCKS
1087	Candy Cane Seed	CROPS
1089	Candy Cane Block	BLOCKS
1090	Compact Snow	BLOCKS
1091	Compact Ice	BLOCKS
1092	Ice Brick	BLOCKS
1093	Christmas Present 2021	MISC
1094	Frost Sword	COMBAT
1095	Frost Hammer	COMBAT
1096	Christmas Tree	DECOR
1097	Blue Ornament	DECOR
1098	Orange Ornament	DECOR
1099	Green Ornament	DECOR
1100	Red Ornament	DECOR
1101	Cletus Ornament	DECOR
1102	Slime Ornament	DECOR
1103	Cow Ornament	DECOR
1104	Pig Ornament	DECOR
1105	Red Nutcracker	DECOR
1106	Blue Nutcracker	DECOR
1107	Green Nutcracker	DECOR
1108	Pineapple Totem	TOTEMS
1110	Pineapple Seeds	CROPS
1115	Snowman (Furniture)	DECOR
1116	Train Bed	DECOR
1117	Snowman Couch	DECOR
1118	Snowman Bean Bag	DECOR
1119	Candy Cane Lamp	DECOR
1122	Bell (Christmas)	DECOR
1123	Red Envelope 2022	MISC
1124	Tiger Coin Bag	DECOR
1125	Lucky Coin Bag	DECOR
1127	Tiger Jacuzzi	DECOR
1128	Tiger Bean Bag	DECOR
1129	Stacked Lunar Lantern	DECOR
1130	Lion Lounge	DECOR
1132	Lunar Drum	DECOR
1133	Lunar Gate	DECOR
1134	Lunar Lamp	DECOR
1135	Stacked Star Lunar Lantern	DECOR
1136	Star Lunar Lantern	DECOR
1137	Lunar Lantern Small	DECOR
1140	Fortune Cookie	FOOD
1155	Duck Spawn Egg Tier 2	ANIMALS
1156	Duck Spawn Egg Tier 3	ANIMALS
1161	Potato and Duck Egg Scramble	FOOD
1177	Fertile Red Tulip	FLOWERS
1179	Fertile Yellow Tulip	FLOWERS
1181	Fertile Orange Tulip	FLOWERS
1182	Orange Tulip	FLOWERS
1183	Fertile Light Green Tulip	FLOWERS
1184	Light Green Tulip	FLOWERS
1185	Fertile Dark Green Tulip	FLOWERS
1186	Dark Green Tulip	FLOWERS
1187	Fertile Pink Tulip	FLOWERS
1188	Pink Tulip	FLOWERS
1189	Fertile White Tulip	FLOWERS
1190	White Tulip	FLOWERS
1237	Yak Spawn Egg Tier 2	ANIMALS
1238	Yak Spawn Egg Tier 3	ANIMALS
1240	Bhutan Butter Tea	FOOD
1242	Gondo Datshi	FOOD
1244	Copper Block	BLOCKS
1245	Red Bronze Block	BLOCKS
1246	Opal Block	BLOCKS
1249	Oil Fuel	INDUSTRIAL
1250	Petroleum Fuel	INDUSTRIAL
1251	Infernal Hammer	COMBAT
1252	Infernal Flame	MINERALS
1253	Maple Syrup (Glitched)	FOOD
1254	Desert Island Treasure Chest	MISC
1255	Slime Island Treasure Chest	MISC
1256	Maple Isles Treasure Chest	MISC
1257	Wizard Island Treasure Chest	MISC
1258	Buffalkor Island Treasure Chest	MISC
1259	Spirit Island Treasure Chest	MISC
1260	Opened Cauldron 2021	MISC
1261	Ruby Skorp Claw	MISC
1262	Conveyor Ramp Up	INDUSTRIAL
1265	Horse Spawn Egg Tier 2	ANIMALS
1266	Horse Spawn Egg Tier 3	ANIMALS
1267	Blast Furnace	INDUSTRIAL
1272	Spirit Spellbook	COMBAT
1273	Pearl Block	BLOCKS
1274	Buffalkor Crystal Block	BLOCKS
1283	Ruby Sword	COMBAT
1284	Void Block	BLOCKS
1287	Chrome Glass Block	BLOCKS
1288	Fertile Black Chrysanthemum	FLOWERS
1289	Fertile Red Chrysanthemum	FLOWERS
1290	Fertile Pink Chrysanthemum	FLOWERS
1291	Fertile Purple Chrysanthemum	FLOWERS
1292	Fertile White Chrysanthemum	FLOWERS
1293	Fertile Chrome Chrysanthemum	FLOWERS
1294	Fertile Blue Chrysanthemum	FLOWERS
1295	Fertile Cyan Chrysanthemum	FLOWERS
1296	Fertile Light Green Chrysanthemum	FLOWERS
1298	Purple Chrysanthemum	FLOWERS
1299	White Chrysanthemum	FLOWERS
1300	Chrome Chrysanthemum	FLOWERS
1301	Blue Chrysanthemum	FLOWERS
1302	Cyan Chrysanthemum	FLOWERS
1303	Light Green Chrysanthemum	FLOWERS
1316	Glass of Milk	FOOD
1317	Blueberry Cookie	FOOD
1319	Thomas Lucky Fishing Rod	TOOLS
1320	Slime Queens Scepter	COMBAT
1321	Trouts Fury	COMBAT
1323	Large Crate of Pineapple	CROPS
1330	Dragonfruit Totem	TOTEMS
1331	Serpents Hook	COMBAT
1332	Serpents Bane	COMBAT
1333	Serpents Scale	INDUSTRIAL
1334	Serpents Fang	INDUSTRIAL
1336	Amethyst Block	BLOCKS
1337	Amethyst Crystal	MINERALS
1338	Void Potion	COMBAT
1341	Void Stone Block	BLOCKS
1342	Respawn Block	BLOCKS
1343	Tier 2 Conveyor Ramp Down	INDUSTRIAL
1344	Void Mattock	TOOLS
1345	Void Mattock Hilt	TOOLS
1347	Void Parasite Seeds	CROPS
1349	Serpent Egg	MISC
1369	Yellow Butterfly Jar	ANIMALS
1370	White Butterfly Jar	ANIMALS
1371	Red Butterfly Jar	ANIMALS
1372	Silver Butterfly Jar	ANIMALS
1373	Green Butterfly Jar	ANIMALS
1374	Blue Butterfly Jar	ANIMALS
1375	Butterfly Festival Trophy	DECOR
1376	Golden Net	TOOLS
1377	Butterfly Event Bench	DECOR
1378	Butterfly Event Archway	DECOR
1379	Rabbit Topiary	DECOR
1380	Frog Topiary	DECOR
1382	Yellow Daisy	FLOWERS
1383	Yellow Tulip	FLOWERS
1384	Red Daffodil	FLOWERS
1385	Red Daisy	FLOWERS
1386	Red Rose	FLOWERS
1387	Red Tulip	FLOWERS
1388	Pink Chrysanthemum	FLOWERS
1389	Yellow Hyacinth	FLOWERS
1390	White Rose	FLOWERS
1391	Blue Rose	FLOWERS
1393	Red Butterfly Lantern	MISC
1394	Green Butterfly Lantern	MISC
1400	Iron Shortbow	COMBAT
1401	Golden Shortbow	COMBAT
1418	Hardened Bow Limb	COMBAT
1451	Cauldron 2022	MISC
1452	Opened Cauldron 2022	MISC
1454	Candy Basket 2022	DECOR
1455	Halloween Event Trophy 2022	DECOR
1456	Lying Closed Coffin	DECOR
1457	Lying Opened Coffin	DECOR
1458	Standing Closed Coffin	DECOR
1459	Standing Opened Coffin	DECOR
1460	Group of Ghosts	DECOR
1461	Happy Ghost	DECOR
1462	Evil Ghost	DECOR
1463	Surprised Ghost	DECOR
1465	Small Fire Chalice	DECOR
1466	Tall Fire Chalice	DECOR
1467	Long Crossbow Bolt	COMBAT
1468	Pumpkin Candle	DECOR
1469	Pumpkin Angry	DECOR
1470	Pumpkin Happy	DECOR
1471	Wooden Mallet	COMBAT
1472	Granite Hammer	COMBAT
1479	Gravestone - All 3 Versions 2022	DECOR
1482	Green Eyed Scarecrow	DECOR
1483	Yellow Eyed Scarecrow	DECOR
1509	Large Diamond Chest	INDUSTRIAL
1510	Expanded Diamond Chest	INDUSTRIAL
1516	Spider Pet Spawn Egg	ANIMALS
1517	The Reapers Crossbow	COMBAT
1518	The Reapers Scythe	COMBAT
1519	Tier 2 Conveyor Belt	INDUSTRIAL
1642	Christmas Present 2022	MISC
1643	Blue Gnome Bag	DECOR
1644	Yellow Gnome Bag	DECOR
1645	Red Gnome Bag	DECOR
1646	Blue Standing Gnome	DECOR
1647	Yellow Standing Gnome	DECOR
1648	Red Standing Gnome	DECOR
1649	Blue Cup Gnome	DECOR
1650	Yellow Cup Gnome	DECOR
1651	Red Cup Gnome	DECOR
1652	Santa Stocking	DECOR
1653	Elf Stocking	DECOR
1654	Snowman Stocking	DECOR
1655	Snowflake Stocking	DECOR
1656	Cookie Stocking	DECOR
1657	Candy Cane Fence	DECOR
1658	Candy Cane Light Fence	DECOR
1659	Santa Plushie	DECOR
1660	Gnome Plushie	DECOR
1661	Elf Plushie	DECOR
1663	Reindeer Plushie	DECOR
1664	White Reindeer Plushie	DECOR
1665	Candy Cane Scepter Weapon	COMBAT
1666	Christmas Event 2022 Trophy	DECOR
1667	Penguin Pet Spawn Egg	ANIMALS
1668	Christmas Fence Light	DECOR
1669	Red Christmas Street Light	DECOR
1670	Green Christmas Street Light	DECOR
1671	Black Christmas Street Light	DECOR
1672	Rainbow Candy Cluster	DECOR
1673	Red Candy Cluster	DECOR
1674	Green Candy Cluster	DECOR
1675	Red and White Christmas Lantern	DECOR
1676	Green and White Christmas Lantern	DECOR
1677	Red and Green Christmas Lantern	DECOR
1678	Green Page	INDUSTRIAL
1679	Blue Page	INDUSTRIAL
1680	Red Page	INDUSTRIAL
1681	Jolly Dagger	COMBAT
1713	Cherry Blossom Sapling	LUMBER
1722	Lunar Mooncake	FOOD
1723	Lunar 2023 Rabbit Statue	DECOR
1724	Lunar Rabbit Plushie	DECOR
1725	Lunar Rabbit Banner	DECOR
1726	Dumpling Couch	DECOR
1728	Dumpling Chair	DECOR
1729	Red Envelope 2023	MISC
1730	Gold Envelope 2023	MISC
1732	Industrial Truffle Barrel	INDUSTRIAL
1733	Industrial Nest	INDUSTRIAL
1738	Noxious Stinger	COMBAT
1747	Skorp Serpents Scale	MISC
1748	Skorp Serpents Tooth	MISC
1751	Vulture Spawn Egg Tier 2	ANIMALS
1752	Vulture Spawn Egg Tier 3	ANIMALS
1758	Toxin Potion	COMBAT
1759	Islands Third Anniversary Cake	DECOR
1760	Islands Second Anniversary Cake	DECOR
1761	Confetti Popper	MISC
1762	Sparkler	MISC
1763	Party Horn	MISC
1764	Glow Stick	MISC
1765	Cletus Plushie	DECOR
1766	Dog Pet Spawn Egg	ANIMALS
1767	Glitterball	MISC
1769	Draven Statue	DECOR
1770	Mining Event Trophy 2023	DECOR
1771	Red Dynamite Box	DECOR
1772	Wooden Dynamite Box	DECOR
1773	Dynamite Wall Decor	DECOR
1774	Black Mining Lantern	DECOR
1775	Brown Mining Lantern	DECOR
1776	Gold Mining Lantern	DECOR
1777	Mining Couch Green	DECOR
1778	Mining Couch Purple	DECOR
1779	Mining Entrance	DECOR
1780	Mining Gem Bag	DECOR
1781	Mining Tool Bag	DECOR
1782	Jade Plushie	DECOR
1783	Sandbag	DECOR
1784	Sandbag Pile	DECOR
1785	Sandbag Stack	DECOR
1799	Slime Mural 5	DECOR
1800	Gold Small Brazier	DECOR
1801	Gold Tall Brazier	DECOR
1802	Primordial Plushie Beanbag	DECOR
1803	Primordial Statue	DECOR
1804	Dungeon Chest	MISC
1805	Opened Dungeon Chest	INDUSTRIAL
1807	Fertile Purple Lavender	FLOWERS
1808	Fertile White Lavender	FLOWERS
1809	Fertile Red Lavender	FLOWERS
1810	Red Lavender	FLOWERS
1811	Fertile Pink Lavender	FLOWERS
1812	Pink Lavender	FLOWERS
1813	Fertile Black Lavender	FLOWERS
1814	Black Lavender	FLOWERS
1815	Fertile Blue Lavender	FLOWERS
1816	Blue Lavender	FLOWERS
1817	Fertile Yellow Lavender	FLOWERS
1818	Yellow Lavender	FLOWERS
1819	Fertile Cyan Lavender	FLOWERS
1820	Cyan Lavender	FLOWERS
1821	Fertile Light Green Lavender	FLOWERS
1822	Light Green Lavender	FLOWERS
1823	Fertile Dark Green Lavender	FLOWERS
1824	Dark Green Lavender	FLOWERS
1825	Fertile Orange Lavender	FLOWERS
1826	Orange Lavender	FLOWERS
1827	Fertile Chrome Lavender	FLOWERS
1828	Chrome Lavender	FLOWERS
1829	Cyan Glowing Mushroom	DECOR
1830	Green Glowing Mushroom	DECOR
1831	Pink Glowing Mushroom	DECOR
1832	Blue Glowing Mushroom	DECOR
1833	Yellow Mushroom Table	DECOR
1834	Cyan Mushroom Table	DECOR
1835	Red Mushroom Table	DECOR
1836	Pink Mushroom Table	DECOR
1837	Glowing Blue Mushroom Block	BLOCKS
1838	Glowing Cyan Mushroom Block	BLOCKS
1839	Glowing Green Mushroom Block	BLOCKS
1840	Glowing Pink Mushroom Block	BLOCKS
1841	Cyan Trunk Chair	DECOR
1842	Red Trunk Chair	DECOR
1843	Yellow Trunk Chair	DECOR
1844	Pink Trunk Chair	DECOR
1848	Cyan Outhouse	DECOR
1849	Pink Outhouse	DECOR
1850	Red Outhouse	DECOR
1851	Yellow Outhouse	DECOR
1852	Dark Brown Nature Fridge	DECOR
1853	Light Brown Nature Fridge	DECOR
1854	Purple Nature Fridge	DECOR
1855	Tan Nature Fridge	DECOR
1856	White Nature Fridge	DECOR
1857	Mushroom Event Trophy 2023	DECOR
1858	Natures Divine Longbow	COMBAT
1859	Poison Long Arrow	COMBAT
1860	The Divine Dao	COMBAT
1861	Koi	ANIMALS
1862	Cursed Grimoire	COMBAT
1863	Cursed Hammer	COMBAT
1864	Cat Pet Spawn Egg	ANIMALS
1865	Mansion Cabinet	DECOR
1866	Mansion Bench	DECOR
1867	Mansion Desk	DECOR
1868	Mansion Bust Pink	DECOR
1869	Mansion Bust Blue	DECOR
1870	Mansion Bust Green	DECOR
1871	Mansion Bed	DECOR
1872	Mansion Rocking Horse	DECOR
1873	Mansion Couch	DECOR
1874	Mansion Grandfather Clock	DECOR
1875	Wraith Boss Plushie	DECOR
1877	Cauldron 2023	MISC
1878	Opened Cauldron 2023	MISC
1879	Halloween Event Trophy 2023	DECOR
1880	Oak Wood	LUMBER
1881	Birch Wood	LUMBER
1882	Cherry Blossom Wood	LUMBER
1883	Hickory Wood	LUMBER
1884	Maple Wood	LUMBER
1885	Pine Wood	LUMBER
1886	Spirit Wood	LUMBER
1887	Plate Factory Mold	INDUSTRIAL
1888	Seaweed Seeds	CROPS
1889	Void Grass Block	BLOCKS
1890	Void Sand Block	BLOCKS
1891	Spirit Seeds	CROPS
1892	Spirit Flower Pot	DECOR
1893	Spirit Flower Vase	DECOR
1894	Spirit Jar Light	DECOR
1895	Spirit Lantern	DECOR
1896	Spirit Plant	DECOR
1897	Spirit Statue	DECOR
1898	Spirit Stool	DECOR
1899	Spirit Table	DECOR
1900	Hanging Spirit Light	DECOR
1901	Spirit Essence Holder	DECOR
1902	Butterfly Couch	DECOR
1903	Butterfly Lamp	DECOR
1904	Small Bush Pot	DECOR
1905	Medium Bush Pot	DECOR
1906	Tall Bush Pot	DECOR
1907	Frog Topiary Pot	DECOR
1908	Rabbit Topiary Pot	DECOR
1909	Frog Fountain	DECOR
1910	Benched Gazebo	DECOR
1911	Grey Gazebo	DECOR
1912	Purple Gazebo	DECOR
1913	Red Gazebo	DECOR
1914	Purple Plush Butterfly Couch	DECOR
1915	Pink Plush Butterfly Couch	DECOR
1916	Red Flower Chair	DECOR
1917	White Flower Chair	DECOR
1918	Cyan Flower Chair	DECOR
1919	Ladybug Ottoman	DECOR
1920	Bee Ottoman	DECOR
1921	Steel ATM	INDUSTRIAL
1922	Gold ATM	INDUSTRIAL
1923	Diamond ATM	INDUSTRIAL
1924	Workbench (tree stump)	INDUSTRIAL
1925	LED Light	INDUSTRIAL
1926	Timer	INDUSTRIAL
1927	Turkey Trophy	DECOR
1928	Kiwifruit Tree Sapling	CROPS
1929	Spirit Bench	DECOR
1930	Spirit Crystal	MINERALS
1931	Spirit Lava Lamp	DECOR
1932	Spirit Bed	DECOR
]]

for line in itemData:gmatch("[^\r\n]+") do
    local parts = {}
    for part in line:gmatch("%S+") do
        table.insert(parts, part)
    end
    if #parts >= 3 then
        local id = tonumber(parts[1])
        local name = table.concat(parts, " ", 2, #parts - 1)
        local category = parts[#parts]
        if id and name and category then
            if not items[category] then items[category] = {} end
            table.insert(items[category], {id = id, name = name})
        end
    end
end

-- Sort items by ID in each category
for cat, list in pairs(items) do
    table.sort(list, function(a, b) return a.id < b.id end)
end

-- Scan for all remotes
function scanRemotes()
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            table.insert(remotes, obj)
            print("Found remote: " .. obj.Name .. " at " .. obj:GetFullName())
        end
    end
    print("Total remotes found: " .. #remotes)
end

-- Scan for all functions
function scanFunctions()
    for _, func in pairs(getgc()) do
        if type(func) == "function" then
            local info = debug.getinfo(func)
            if info.name then
                table.insert(funcs, func)
                print("Found function: " .. info.name)
            end
        end
    end
    print("Total functions found: " .. #funcs)
end

-- Create UI with item browser
function createUI()
    screenGui = Instance.new("ScreenGui")
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 600, 0, 400)
    frame.Position = UDim2.new(0, 50, 1, -350)
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.BackgroundTransparency = 0.5
    frame.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 20)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Text = "Islands Item Duplicator"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    title.Parent = frame

    -- Category buttons on left
    local catFrame = Instance.new("Frame")
    catFrame.Size = UDim2.new(0, 150, 1, -20)
    catFrame.Position = UDim2.new(0, 0, 0, 20)
    catFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    catFrame.BackgroundTransparency = 0.3
    catFrame.Parent = frame

    local catScroll = Instance.new("ScrollingFrame")
    catScroll.Size = UDim2.new(1, 0, 1, 0)
    catScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    catScroll.BackgroundTransparency = 1
    catScroll.Parent = catFrame

    local yPos = 0
    for cat, _ in pairs(items) do
        local catButton = Instance.new("TextButton")
        catButton.Size = UDim2.new(1, -10, 0, 25)
        catButton.Position = UDim2.new(0, 5, 0, yPos)
        catButton.Text = cat
        catButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        catButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        catButton.Parent = catScroll
        catButton.MouseButton1Click:Connect(function()
            showCategory(cat)
        end)
        yPos = yPos + 30
    end
    catScroll.CanvasSize = UDim2.new(0, 0, 0, yPos)

    -- Item list on right
    itemFrame = Instance.new("ScrollingFrame")
    itemFrame.Size = UDim2.new(1, -160, 1, -70)
    itemFrame.Position = UDim2.new(0, 160, 0, 20)
    itemFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    itemFrame.BackgroundTransparency = 0.3
    itemFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    itemFrame.Parent = frame

    -- Bottom controls
    local bottomFrame = Instance.new("Frame")
    bottomFrame.Size = UDim2.new(1, -160, 0, 50)
    bottomFrame.Position = UDim2.new(0, 160, 1, -50)
    bottomFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    bottomFrame.BackgroundTransparency = 0.3
    bottomFrame.Parent = frame

    local idLabel = Instance.new("TextLabel")
    idLabel.Size = UDim2.new(0, 50, 0, 20)
    idLabel.Position = UDim2.new(0, 5, 0, 5)
    idLabel.Text = "ID:"
    idLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    idLabel.BackgroundTransparency = 1
    idLabel.Parent = bottomFrame

    idTextBox = Instance.new("TextBox")
    idTextBox.Size = UDim2.new(0, 80, 0, 20)
    idTextBox.Position = UDim2.new(0, 30, 0, 5)
    idTextBox.Text = ""
    idTextBox.PlaceholderText = "Item ID"
    idTextBox.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    idTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    idTextBox.Parent = bottomFrame

    local amountLabel = Instance.new("TextLabel")
    amountLabel.Size = UDim2.new(0, 60, 0, 20)
    amountLabel.Position = UDim2.new(0, 120, 0, 5)
    amountLabel.Text = "Amount:"
    amountLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    amountLabel.BackgroundTransparency = 1
    amountLabel.Parent = bottomFrame

    amountTextBox = Instance.new("TextBox")
    amountTextBox.Size = UDim2.new(0, 80, 0, 20)
    amountTextBox.Position = UDim2.new(0, 175, 0, 5)
    amountTextBox.Text = ""
    amountTextBox.PlaceholderText = "Amount"
    amountTextBox.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    amountTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    amountTextBox.Parent = bottomFrame

    addButton = Instance.new("TextButton")
    addButton.Size = UDim2.new(0, 100, 0, 25)
    addButton.Position = UDim2.new(0, 270, 0, 10)
    addButton.Text = "Add Item"
    addButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    addButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    addButton.Parent = bottomFrame

    addButton.MouseButton1Click:Connect(function()
        addItem()
    end)

    frame.Visible = false
end

-- Show items for selected category
function showCategory(cat)
    -- Clear previous items
    for _, child in pairs(itemFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local yPos = 0
    for _, item in pairs(items[cat] or {}) do
        local itemButton = Instance.new("TextButton")
        itemButton.Size = UDim2.new(1, -10, 0, 20)
        itemButton.Position = UDim2.new(0, 5, 0, yPos)
        itemButton.Text = item.name .. " (" .. item.id .. ")"
        itemButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        itemButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        itemButton.Parent = itemFrame
        itemButton.MouseButton1Click:Connect(function()
            idTextBox.Text = tostring(item.id)
        end)
        yPos = yPos + 25
    end
    itemFrame.CanvasSize = UDim2.new(0, 0, 0, yPos)
end

-- Add item function
function addItem()
    local itemId = tonumber(idTextBox.Text)
    local amount = tonumber(amountTextBox.Text)
    if not itemId or not amount then
        print("Invalid ID or Amount")
        return
    end

    -- Try remotes that seem related to inventory/items
    for _, remote in pairs(remotes) do
        local name = remote.Name:lower()
        local path = remote:GetFullName():lower()
        if string.find(name, "inventory") or string.find(name, "item") or string.find(name, "add") or string.find(path, "inventory") then
            if remote:IsA("RemoteEvent") then
                pcall(function()
                    remote:FireServer(itemId, amount)
                end)
            elseif remote:IsA("RemoteFunction") then
                pcall(function()
                    remote:InvokeServer(itemId, amount)
                end)
            end
            print("Called remote: " .. remote.Name)
        end
    end

    -- Try functions that seem related
    for _, func in pairs(funcs) do
        local info = debug.getinfo(func)
        if info.name then
            local name = info.name:lower()
            if string.find(name, "add") or string.find(name, "give") or string.find(name, "item") then
                pcall(function()
                    func(itemId, amount)
                end)
                print("Called function: " .. info.name)
            end
        end
    end

    print("Attempted to add item ID " .. itemId .. " x" .. amount)
end

-- Key input handler
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.G then
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
            exitScript = true
        else
            uiVisible = not uiVisible
            frame.Visible = uiVisible
        end
    end
end)

-- Main loop
scanRemotes()
scanFunctions()
createUI()

while not exitScript do
    task.wait(0.1)
end

-- Cleanup
if screenGui then
    screenGui:Destroy()
end

print("Script exited")