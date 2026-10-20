-- Detach the previous instance on re-execution.
if shared.Vexora then
	pcall(shared.Vexora.detach)
end

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local Vexora = {
	active = true,
	connections = {},
	drawings = {},
	instances = {},
	espObjects = {},
	hitboxCache = {},
	silent = { part = nil, position = nil, chance = 100, roll = true, rollAt = 0, partAt = 0, partName = nil },
	errored = {},
}

-- Constants.
local DISCORD_LINK = "https://discord.gg/4u5AxArp9Z"
local KEY_FILE = "Vexora/key.txt"
local KEY_URL = "" -- optional raw link, one valid key per line
local VALID_KEYS = { "VEXORA-FREE-KEY" } -- edit this list to your own keys
local DRAWING_OPAQUE = 1
local MENU_WIDTH = 760
local MENU_HEIGHT = 480
local AIM_BIND_NAME = "VexoraAimbot"
local SLOGAN = "quality at its greatest"

local AIM_KEY_NAMES = { "Right Mouse", "Left Mouse", "Q", "E", "Left Shift", "Always On" }
local AIM_KEYS = {
	["Right Mouse"] = Enum.UserInputType.MouseButton2,
	["Left Mouse"] = Enum.UserInputType.MouseButton1,
	["Q"] = Enum.KeyCode.Q,
	["E"] = Enum.KeyCode.E,
	["Left Shift"] = Enum.KeyCode.LeftShift,
}

local MENU_KEY_NAMES = { "RightShift", "Insert", "RightControl", "Delete" }
local MENU_KEYS = {
	RightShift = Enum.KeyCode.RightShift,
	Insert = Enum.KeyCode.Insert,
	RightControl = Enum.KeyCode.RightControl,
	Delete = Enum.KeyCode.Delete,
}

local PART_NAMES = { "Head", "HumanoidRootPart", "Torso" }
local TRACER_ORIGINS = { "Bottom", "Center", "Mouse" }
local rgb = Color3.fromRGB

local ENVIRONMENT_NAMES = {
	"Default", "Blossom", "Pink Paradise", "Night", "Sakura", "Snowy", "Storm", "Sunset", "Dawn", "Midnight", "Synthwave", "Inferno", "Aurora", "Desert", "Deep Sea", "Foggy",
	"Cherry Moonlight", "Neon Tokyo", "Crimson Dusk", "Emerald Jungle", "Golden Hour", "Volcanic", "Cosmic Void", "Candy Sky", "Ocean Sunrise", "Haunted Fog", "Autumn Maple", "Monsoon", "Frozen Dawn",
	"Lavender Dreams", "Tropical Sunset", "Rose Gold", "Arctic Aurora", "Toxic Swamp", "Royal Violet",
}
local WEATHER_NAMES = { "None", "Snow", "Blizzard", "Petals", "Blossom Rain", "Rain", "Heavy Rain", "Leaves", "Ash", "Embers", "Fireflies", "Stardust", "Pollen" }
local SKY_MODES = { "Match Environment", "Game Default", "Roblox Classic" }

local CROSSHAIR_STYLES = { "Classic", "T Shape", "X Cross", "Star", "Diamond", "Square", "Triangle", "Arrows", "Target", "Circle", "Dot" }
local COLOR_MODES = { "Static", "Rainbow", "Pulse", "Pastel" }
local EFFECT_PRESETS = { "None", "Cinematic", "Vivid", "Dreamy", "Noir", "Retro", "Neon Glow", "Ultra Quality" }

-- Embedded images (your logo plus particle textures, written to the workspace on first run).
local LOGO_B64 = "iVBORw0KGgoAAAANSUhEUgAAAMAAAADACAMAAABlApw1AAAA/1BMVEXfXp3UI2HyKKSpJE7cjqxnFB3uytqYFSHRSXOsUWj2ZsPon9bfDiqzcYd8MEMvEAcWEAsXCAgcCAn9+PRuBxGPBxOtCBhUCA/sCDEnBQX1B2/xB03RCCovBQY3BgghBQb4B4v56fJHBwyxCCrLBxv22e3pJ3POFkvpGG7vWK+tFDFBBwvtqNA9BgiQCin0xun0SK3uttbqNo3tFE+QEir1eMbrJovuhcntZ7POEjTrmNDvF5H1uefVJ2pzCiZyFSwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAC2rLetAAAAQHRSTlP///////7///////////9uCA8i//////b/Tf///2yNNf//zv//////////t/+m////////////////////////ixqzGAAAEEpJREFUeNrtXWd74jgXlQstZHZfZNnCuAUbY5pNKKEG+P//6r0ykCEZioyp+4w+7MxODJxz77lNlgkqnb/wWT9K+iH4+Meg0pMvdFnL34EAflLL4xQeeHoJXd+sNyGAHyMu/kromQjg+4cIXte2C3oA3zvK0V0Mea798SPEAP7PBDFmfRo+xROf6PDumoUwfmoPbOyL02kN3VfT+JyX4zMJ4KTjxtkEErwnRmlNfO/qhm6gk6sK8tEIPEAWwvgvgb/t9ON3QBchsL+K4qfwAN7gxxczO76LhDB+3hjA+MmD+OoEcGoCj2JifPxn6GqmuWBRxNeQ0O1IOLodtl3XtfV9ykWlx2WA9ZCSZeRJwWKxEBaBp1LrDwiP2ko4FiWqJzT6TTT77PrVatXvjkfl6VI/fyK7jV4c+I/lksgTKqPm+LOq7KxuvdH7ZT00gVJJt2Pw8y/wYHxl85euiJTOEj8wAd0lmgm6QUW/GkP/5gCl2ukgVHAelYBOiScYjfcPMH31D/AbERUV2blhO40ToS8DerkL4ervBQ/LL/byOXw9At83WTjRs6htE88E9OOuD+sAeLZmk0FZvc1AE6PXdR4H2aB7w+ijnu9ns0fQgwMQKg8oFwGconn7fSV29dPSUc2yUZ/Mun7WP4oeVrE5MFr6cQIHu4+zKq+9dI6ydNUaSAeNP7un0StKD9XLr+QGM/EOV5I5fJlFtBozfuez2z2Nfi2gcsv5IQnEiQifR0Af0gOh66pauQzG7/Sy/rpMnSLw0hyUp/TnpyDuBHOeN2jL2vNmFlVj488AfnW33LKWpzNGE7Re486n/5WBQEC7KQinlRAnIzX644VtSDvlAUKztfG32P3P2UezXx8YRtncrPKgPxmvf9xBAghIv/2+UDglP9NODbTz/lEsZr9sX/WL4xdUH5TLpqepGUrbYWjbbaKaZr2JqnEA58vlafv2G1u4RKbhb5fpzPjGqPlS7H1pAyw/AfCGaeYIdS0d704EpCagGbQQLICndI8Crk/AabX0TQSFrGRVoMUvbgsW6Gbc7A+M8hTsbv88fsFeppYR2uAnzj22FrFDg2gtfUj65YbYfOn4W/Sdj/cRmN4D8M7ebT5coq/12WecQKlzYibGV6kF8Jeoviyt805DRMXexvgMPajeVElbP3irzClRUxijpmGq9hV25jiX5QWRxxoGEaHejnIaA0Bvn+g2qNDxkWFmrrK1yNluUskYTd5HMKZk1/C7DP3UhBkdwwx53PMrX5HNVvugQq5PQFdH78YE4nDmb4TPcs50SGyHpz5K1WxA9NLBm/roatsmeL25AA2PYQiou6m4n2MQ/lQjru5gh+MzdO8jT392At+O2yTvERK8wCa11/KgUkHrwPVnk34j8FQS6o6uc30WCRbtowjQFXeoLMLy5nyOOut6xYxv1lRq2/pGESetFwoNempzF19pozketCpv83XiAeVDm2NqKqG27nA6E1vSfHniY6518NViPcMWfpx2IOVr0CrYDq8awUlDMTqFDznXCOEYvlFZw/eLrGLFxm87id5miaSTSC6dRnEM3ysD/Ldmbxu4MXzX1pPZhYrS6YvQxfFDw8ngV2Lrd2fNUeOVaadtOQl96y4kjluJiWMAH/t/kO1aPBv44+a626G2nvitabDiwYNKKQl8/yH9Bp81a7UcaX/Bt/iDYIs/XQzs9x4+2PSwbYZKRWR5/3Mbue3fI4oliStOj1NpxXfhUQkdLBF434VtNYbfn7EJMIZvxvB3klPwjohz+pgZTAEtwukpdKGmoRSyUdeoiMWN9aemlos7/W929RByOd6WtChveUUX2EiBC5115hTlKoPfrE81ljf/jFw76sjWyQaODO3SBU4tYu432cAXkM/go0VLUwG+tafbhNnAL5wIZD2TS1DvLnD4O049gB91Af64KbRUNUcObevaBFWlE1U8k6Reo9T42yqgB/idOO8LQwLWpwfTvuMOP/1jCSZc0UQJHaWEb5HY+uJsA/+Y9bcuUHqHMbZXdjIM6TyAY/EbAsRudy2eaAWD7lGF06GsyOGB93MpPnDMnocATpg7MQX4TPw+tGxNkWk/w+6lH//8NhF6CrL3h6+Lk6Zv9DNx8rO3VPMVzC/2lOpsgiSwvkqt0/EHSRLCvbBPZo6VvI1H51Yuh5iGEaunOmsy+Or2JMOpN3GJNFGUwoV20tCZ+KkXw0fd7oeIFpD3c5Q3+ixwwUypSpeZBRF3vtrZ7ivZ6ivALwuzXnM0YrGrkhBzpy5K8iir+P/gdA3A2QRAxeZg8Gp6qIOERr2lEujZHO4uCkMmjcYQ+NkMvo0H8I87l23PGEw9VZJRo1IPVEKgbiU6YKkTkh8LjMGNJPTt062lMAg0dSiD+euCx+Dbh+a+Q7QoaXUmQpb54H8XJID5gncggGYKPdRoCC2An2nrCftxMAKJQH5e7xI+SPAEB2bBO51GhOQ6HRD/Rj1nzKAOUZH4iVRZ8VPnokQSop4H+UZFn81GXdAIZS3zWZM0BMFo3kXQFlUL32/NJH4qKAEBnfWZqir1xov6AtSTyVi8kfMzQigp9CvzT5kUfKVgpapo3ASwTVi1VeUeqtRzIB7S5rcW/qMYo3zljTFgnZ2bZj8EcQavRWP4hZ68qEMUkwy1SkkT2I6EpKxQeXubF2VKUVde4lQEeF7rqiq0C5A7+3HlIsRKtactKdWgUnmrVMadlSuhiWSdh56XgEVUDab0QgetzU/sVIkDlwpZZDL8lcqkJ9lEEAXinBsD+DRPl8HXcsz8C2b+xOr5I422gpr59hYz6HcKtus1GpGVdBLg9YBDmPXB/BOhDl0zIWHq4uN65aD/tl6V+VjOWERqbG7lXZyAvcaPwPyCBvBdPXULZkmynC2+ifO5KM7BDUgu2DY0iC2iXzyNYqrVAL7UGTfqObbd8G/69gtn2P3WovjeZEucV4wBQhkrhCrvJY8udKJ2rc0Pnc/CY+rR0+PX/4EROqvMJpMPdqbpRXwzyuW8/Cujh6Q1naouvhyBtgrmh1ozE+PkQ620z97G7ciH35Gy1Y+Xj/US3ypsa6A5K1DLBgqmt/yxL4PPIsAOimivLHp7aDFifedO25n4rgjebmupZqUReLIynry8fKAdAsboZVbItEOqtoIgiLgnPHQk+Zu1XNw6jJj53X+/7deccX88pJFnGhXD9OTqB0TAZDJ5+Xh52RBghfllhiRCKYk5CN4y07bOJBDvGJpsVO/MRCGIk8/5WV+3XEoiSajMR/25YRZ6n++iGMcwuGGHAFBojmUkRaxpiTwBViB50ZId43IOSfKQB1yN4c93JyMhYvJx+MXDvm7BAdS2S+lyGUWSJIrovfkyns2KEyEvF1/eREYgzkIbAkalsqkLo/cmyi/AA63WMIo8SQgEYbFYSJI0XC2XtB3alo7x7/72gAdIraZpntxFfWE7tfBoBlshKCCKhl5LkoJg0Bj135vvYr+PmizjCKP+x8cLg7lmAAt+uibwtqnMhlEeCPVFo9Go14X8wmO1Z7kcDiWmKiEIptNWq+VFEXTz1IVhFu3dsVUZ/lanI/Yl1njq3NJ3LJsZPl7wCUA+Gg61eEE7qHlmYBiN0fxN/OIgfhGIwcMyzVqtZpqCYMDYFLSIy96QENaDxWvJTEoBvW1beK8HQu0VCOR9eSQMmXxK2y+VwXtump12jG63IQYymbgfZ22VFwSNufibgBErCPCXywC9tuYLVzWEFY2xk9jcrhva+h/BgPZ1KoDfRD7IJ26cz8v5P6liiIqQGXJLojFiFF5+EzDKzPSat/aXJMQJiQmAhoAb82Uh7JSoAIaI5S+xl+OEqf7UZbq9ZeEFoxFzBEA3mPqZ/Rm12PwAn7kNEhA+7uyfm7sOEYzXmtnpCX029rqlSy685Wq7aw7T+mjEpB8TMICAt4mXvASXEJej9P84saUvR4NyTYDBEQ1p2sHlEIt4F99qZ8DBaqteb8QSYgRMc0NAkHT6VXqOHGjCP29w4GVzBPi7kwbIP0es0jWXw4wcUxjESYjFwBp/IOntTHhGL4RX8tioFfxmPc/SlnM98BtMrETHFDZBbK7zj0BtGnJ2XLsEnFU2G0D6RAuGn543ZCdlEntB6DeAQbm2IdCyafuMdtrJZKuCivw+2F9VaekWi21XUkKJV+9DEGwJRDr/2I129JNV8hrqjuoFoubc0u1WuHbCVxB7Kz3EyR9Jj/HLXYHZn+HHV5XO91rNnNAShHUVVlsS5u99vwisegrS5M9GPQ9NdHjrJ+pt1jUJi3URyCGSnADtKLIpdxsNBN24W0r9zVOJdypY07NmoJJsZ8X/rQbrI85UVjrQPowMNIzxp3TAGfs7kI6AgcD6JFpQfiXamcOl9i8lG8j+yBAkNZc+/+BTp4H3PqzhZtpEyDMCBPHfRY7PTlsFRRFQtV+pC6qaYU+FXygGcKJ/t8EHkqDVVJ0ME6VR/I+voLwyqTTqIMAr9A+8irIYg7xpUmwnCmIIgGy+OnurNKYsAfGO6g6/wXn9qUODJyEjwnqSOuBEsiJ3uyMgoGnkaA+5A9PR+R/Z5T8gb0FJk5Bp80sYCFANKYr/Dv2goA5DDh3ouo6vJCKsw+QpCaSUQEIO0WRF+ZgDAVMlJyMSGvmfT6xddFnQhwUe/94igthXZaXINroXeTU8NZ9bdmidMdgnY6BN+VM5YjdPs0qTzaZSTz5WAaFYZvbv7172GRAbZs2IO/ciigTP/2QbBG+elP9O4HfwxZMHPXSqAF929AmhHBPuk7u0U0XoQ2QSMlU1sv8krMPMMRx+nSa79Dd/7XlCrA0MeOMM6ZGUr4/EOQTxpNfzC992cfU2iYat1nCrnFv1qDTnEc4nDhAmmlafx/uq4It8oBIa2rDadBlJgSC1lq5+UXCY5woKHRHv2Wm4lj0vxe54TsyayYaKWq02nU4DabikdukuC3K72uYc6nWS0xhmE9Dn4E8Y7KZTL0c22f5O38fmqC2Vy3jQTmMKM+RmR1Vj5/c4H3m57rJUyETcA028gRyvcPvACL7vF7Xhkq21Qo7QebTvmdtRLPVyP75QCx/0wE6rU3qcRV4Jr4Qec+lqq82RhR52YQhk1boFgd1Me1mHhjly6jzqRQhcs6c40VjjB/8VFpgMwxtI6JoMVPVpg3gz3gzpVb6u81adKQsD/ak9UCplSEoP4Dv7xRnSq3oAX/kVuBQeu92IHkDlp5sicpQATvGZt5GXfuT5RJTOohjfZGKzV/ozdqO7uZQ+cRqN18q+0hck3SpgrKVeujuBVMulTy0hdg7UugaBG6YAx/pKfN+zEL6Mga7MFMcPoe55K3Qtj99q/f01Ln8J3JMATql3fGcCGD9ArD+KhJJ2tbf5rYj4KWLgbxZKZw501gc90BT0t5DdO3r+Ax7AfwncVX1PK6Htg5EonRHwA0gonQ/PO36Grx4D+Ba/0PBSBPBFg+qZCtlD5K/HzUKYz1ro9lA4fch52wI9gUrSEHj8aED3VNDlCDxxQ7dLAD8vgfspGV+EwDOPBI9TyPCzE7i5Bw48LIpvLEl0thfxuUrAF43k/wNZxTqVoA1RkQAAAABJRU5ErkJggg=="
local TEXTURE_B64 = {
	glow = "iVBORw0KGgoAAAANSUhEUgAAAGAAAABgCAMAAADVRocKAAAAflBMVEX///////////////////////////////8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABpC9MhAAAAIHRSTlMGLk5uj67M6QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAPfaS/cAAAEYSURBVHja7ZgLDoMgFARFsN7/xo2mKo9Pq12WxnTnADOB+IE3DEIIIcR/4Sxce+OGq0PWN0k4Ry24M7D9QMFqxpgmhao9b6D+sQxW+Ki3CY4fKBT9fqNBIfd7S17A/D4HKZzxQ4XE72skBdQfDsCCDeT6KAEFzAJCKBbsEoAFhPC2cG0JVf+0US18G0j8pnA9YHbo8E+WpHBljyoLWLWPhVJgRAKJPy1AgX0BsT8qZHsEBVb3vBeaB1b9wqtwy8A8bwVt0U+eIsp7QH+Tmd8i3teU/j/o9kfj/ZPpp4pu5yLeyY5+NuWfrun3A/4Nh39Ho98y+fdk/k2fP6vgT1v48yL+xIs/s+swdeTPTTtMfnvMroUQQgiMJ1PZGyAQTDitAAAAAElFTkSuQmCC",
	petal = "iVBORw0KGgoAAAANSUhEUgAAAGAAAABgCAMAAADVRocKAAAAflBMVEXq6ury8vK+vr7X19fm5ubNzc3KysrX19fn5+fw8PDy8vLW1tbn5+fLy8vX19fKysrLy8vn5+fLy8vn5+fo6OjW1tbY2NjKysrY2Njo6Ojy8vLy8vLW1tby8vLx8fHKysoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACaguZFAAAAIHRSTlObcgD9/fgLCQn6CNDR0S8rUi2tUbBNrm5ybiqPkE/UjuhGG+YAAAJUSURBVHja7dkNkqMgEAVgMg6RJRKUMTE/E73/LRdxUrPZGl+3gFu1VfYB+PK6MYkg3lYusQEbsAEb8D8A+1CrAfvvWgMY17Vd19XWRgsCr2/39WCMcd6IJCBgx89eOymlcUMdJwgUoHOD9cooeKKzMQICrDPO7p+CNEOMIECA2kg3Nmbq0ihEtAkAdjDS1NNOMpPglgsI8J/bdCHBMAFSLhfEfIcmwG+jzj3XjxAEHIGUw8vyX0JOwD9l8rUWChTwQy0TZoGyPB2KH+vweSzLNYFlQgxQHC7HHMDxPAcU5xM7QhxQ8Js0/ySXx895gN8kCByAwG0SAMoLANhjQMAJAdwmIQBNmR0B/KLBKU87KRHAQ/BN4kSAABwCs0nobwsxBN6cMXBJjwABqkecCPC/KdUjTgQMEPso/DKkAafkCPj9gHrWGM8CAVA9Ks7UDwMFUGMmIxCvUHQEaszUSyAdgRgzBahGVO+oqmujkgD10ULgvW2USnlPVs2ViPCRCFARKtEkAXSENhUgI8AeMQ5DlMIRqmsiMG5VGAEOgQUQTWpRj1jnRcScq3QAR4BD4J14eaGKHALzSA1/JbUZANW0cV9H3ENBOAY0ZfapI9pJeQAwhiwAEtA+XXAwOz+GTMC8kA9oru16MwBCNmBOyPGgfZXWt4f49Xfdbzrb8b7W+iH61/X7nc4HBOH+KohHTiC0afdniB51KOoGZBzEd4j+jgLEXbHoQIQUPbF+5B2ODsTu7utxg+tHXxLpYPjSeP2EWyj9rLeVgPQLig3YgA3YgH8G/AbDi3AcW+thJgAAAABJRU5ErkJggg==",
	leaf = "iVBORw0KGgoAAAANSUhEUgAAAGAAAABgCAMAAADVRocKAAAAflBMVEXr6+vr6+vr6+vr6+vr6+vr6+vr6+vr6+sAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACukz3oAAAAIHRSTlMA/W7Pj65QLwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABFAj9kAAAGaSURBVHja7Zk7gsMgEEOZL/e/8ZK14xgYZws01aIyRV5GSNiQUra2tra2tr6KazKAyDwZQCSZY9ChvDGETClzDGnfbJljyOu3y0kg0ZoAIGX6yBgPIFa6CzqGHAssHaF9gAU0X2gUaowzQYNJwNWwtydGgQBjXB0Yl+GUowB9Vm8zwAAUmyQ4gMQm4QAPJjkOEGZ1eRGs629gki0CtK8WfhF6VyKTHAmICq1IQFRogwKirGIBQaHXNrzpB89ZZSxgNsnAgCmrggZMJlUwYCq0owHTa8wKwMOnTJ9VgQPGQlc4YMiqox4IT4Ve2+/iGbqsSgHvR5NJq09+lz+yun4y0e9ZXX79Coe4FVoKQPrNJMibfJVnk0DHQ30sNOrEMw5xZdUKSvxQaNypsB/iKjTyjM6RSdDTcw1eua1AxXNW0VcMNhYafonhg0lc4NLOJMMDrg3wt9BSMqS3rOZciJ1DvEzKutXTd6E1CXDsHc0kKWnSI6uJl6ttCHHhkihuWU0FtA1QcwEtserphOy/AjjbpJLt0dbW1tY/1w/coQk+ChxbNwAAAABJRU5ErkJggg==",
	flake = "iVBORw0KGgoAAAANSUhEUgAAAGAAAABgCAMAAADVRocKAAAAflBMVEX///////////////////////////////8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABpC9MhAAAAIHRSTlMB8NIsrk+NcAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAF/SW4wAAANPSURBVHja7VnbtoQgCB0F4f//+ChaVoKV2ctZ8TTTBQX2BqTf75NPPrkggVi/wRRm6Af0pN8hjzDDAO/D3TuXdacNkrP2CejEtlEzgDxXLaqPZG3CQTvIueiCnh/kXvDO89AC7J0jsD2UrQso+xiDT3yVfG977H200/ahaXoAEA/El53vxBDqEwDhsh0BvUfikKxftndg28IxkidCYErvhMvU9VnS244LqWjPsfyXxYIiN4gNZU+rBeEQCi7YoryA2HubDtGrCUiiiQ+hiM7nEiXkHLHfMFQjTFu2UbnsHmYLUcEK2+SKMOVxqosmhJZtK8ce51Mhkm83Sk44xuPO4Ry8wqWgmSbxETAwDPjGC/wYF0VtdKJtLHAeKQzAuGEb6b5bSIY8FIpCt54FgxQ70C1DVYkBPaHYEaqgEGSK9sXdBxP4EUS1tL/HCXjncJoBvzYn0OMkpHg89KMyM84Tsqjaw/AOorM74I0JQxANBGtDF8ysegLRjpLUQkO3Z65+NyFa+3BolaQWChZnqK/nRq8D0biFch2Udi22iMu1qInANsGC6JmG7fp6N5s1mxCtWg0fxKRZWrO6lgJVq9BXrVWR+YixQjIhFSANoqcvp8RPKYrSyMZtYltGIBcxp5Qv0Qqrg5UHCKOk0pVFilUjuXw6akU6feL6i1nrw2fKwY/vL0B7x3jVRbi83MjmavmlALWGFtLBTgkyZ/3xoaNwOgnKrwjS/EtHWpcI0ql4Z0G40sCA6SmVhWNrSrpL5H2qUpORbB6MXLd5S13hPNktzQuMJbvzdL1mUavedNP1xYLD3YrZLTinJXNTBsyaf6rkYmf0Rtcijqf3+q4MUXitc2z669m9b+uTud27EtW554+fkn+mtqcaLOdBNWZ4dWqWZwzPDoHdY2wZFY0fY08P4vzwIL6OEqh3EMcno4QyDEFzGFKq5+AwZOsJVMc5aFXPgSOyPpCCGSkpJyFjpDYhq4buUHB/9hyhGGN/rCkOHBlr7gaz0BnM8tBg9u5o2d0dLd8djuPd4fit8f7Sq94Z729PTKcfKHgcqtbQV2Ebjy5w5SNR6hgHa1tAuvKZi3E41UHVYnlofexJtnjvU+OhZ248NOdj6eufez/55P/LH+kEF14MURrmAAAAAElFTkSuQmCC",
	streak = "iVBORw0KGgoAAAANSUhEUgAAABAAAABgCAMAAAAjDwKSAAAAflBMVEX///////////////////////////////8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABpC9MhAAAAIHRSTlMNMVFykavL9AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACN1YYAAACKSURBVHja7ZUxDsAgCEULIt7/xqXGAcRqE7VdysYL+YvyOI67gqq9qgekQ0OkR1QACgA9EPRIC4QQKkAGYAYIOoJUSI4gFdIEFGkOYAHYBWyADHAOeR2kecCJl4MoIP5gL9jycku+1Cfb4LZyuMgrdPFEStZjznQNFzZsORRs5WRnbe/18SlQ1+ME8UMLFJqd75EAAAAASUVORK5CYII=",
}

-- Services.
local playersService = game:GetService("Players")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local lighting = game:GetService("Lighting")
local virtualUser = game:GetService("VirtualUser")
local teleportService = game:GetService("TeleportService")
local httpService = game:GetService("HttpService")
local statsService = game:GetService("Stats")
local guiService = game:GetService("GuiService")
local coreGui = game:GetService("CoreGui")

-- State.
local localPlayer = playersService.LocalPlayer
local mouse = localPlayer:GetMouse()
local currentCamera = workspace.CurrentCamera
local guiParent = (gethui and gethui()) or coreGui
local isMobile = userInputService.TouchEnabled and not userInputService.MouseEnabled
Vexora.mouse = mouse

local THEME = {
	bg = rgb(13, 9, 15),
	side = rgb(10, 7, 12),
	panel = rgb(22, 15, 22),
	header = rgb(27, 19, 28),
	row = rgb(30, 21, 31),
	rowHover = rgb(40, 28, 40),
	track = rgb(58, 38, 48),
	line = rgb(78, 44, 62),
	accent = rgb(255, 60, 130),
	accent2 = rgb(255, 130, 175),
	accent3 = rgb(225, 30, 100),
	text = rgb(245, 238, 240),
	subtext = rgb(160, 136, 150),
	good = rgb(80, 235, 120),
	bad = rgb(255, 80, 90),
}

---Connect a signal and track it so detach can clean it.
local function connect(signal, callback)
	local connection = signal:Connect(callback)
	table.insert(Vexora.connections, connection)
	return connection
end

---Run a callback and warn only once per label if it errors.
local function runSafe(label, callback, ...)
	local ok, result = pcall(callback, ...)
	if not ok and not Vexora.errored[label] then
		Vexora.errored[label] = true
		warn("Vexora error in " .. label .. ": " .. tostring(result))
	end
end

---Decode base64 with whichever function the executor exposes.
local function decodeBase64(data)
	if crypt and crypt.base64decode then
		return crypt.base64decode(data)
	end

	return base64decode(data)
end

---Write an embedded image to disk once and return its asset id.
local function loadAsset(name, data)
	if not data or data == "" or not (writefile and getcustomasset) then
		return nil
	end

	local ok, asset = pcall(function()
		if makefolder and not isfolder("Vexora") then
			makefolder("Vexora")
		end

		local path = "Vexora/" .. name .. ".png"
		writefile(path, decodeBase64(data))
		return getcustomasset(path)
	end)

	return ok and asset or nil
end

local logoAsset = loadAsset("logo_v2", LOGO_B64)
local textureAssets = {}

for name, data in pairs(TEXTURE_B64) do
	textureAssets[name] = loadAsset("tex_" .. name, data)
end

--------------------------------------------------------------------------------
-- GUI helpers
--------------------------------------------------------------------------------

local function new(className, properties, parent)
	local instance = Instance.new(className)

	for key, value in pairs(properties) do
		instance[key] = value
	end

	instance.Parent = parent
	return instance
end

local function corner(parent, radius)
	return new("UICorner", { CornerRadius = UDim.new(0, radius) }, parent)
end

local function stroke(parent, color, thickness, transparency)
	return new("UIStroke", { Color = color, Thickness = thickness or 1, Transparency = transparency or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, parent)
end

---Apply an evenly spaced color gradient.
local function gradient(parent, colors, rotation)
	local keypoints = {}

	for index, color in ipairs(colors) do
		table.insert(keypoints, ColorSequenceKeypoint.new((index - 1) / (#colors - 1), color))
	end

	return new("UIGradient", { Color = ColorSequence.new(keypoints), Rotation = rotation or 0 }, parent)
end

local function spinGradient(target, speed)
	task.spawn(function()
		while Vexora.active and target.Parent do
			target.Rotation = (os.clock() * speed) % 360
			runService.RenderStepped:Wait()
		end
	end)
end

---Animated glow outline.
local function glowStroke(parent)
	local outline = stroke(parent, rgb(255, 255, 255), 1.5, 0.15)
	local outlineGradient = gradient(outline, { THEME.accent, THEME.accent2, THEME.accent3, THEME.accent }, 0)
	spinGradient(outlineGradient, 45)
	return outline
end

local function formatNumber(value)
	local text = string.format("%.2f", value)
	return (text:gsub("%.?0+$", ""))
end

---Create the logo image (square, falls back to a text star).
local function makeLogo(parent, size, position, anchor)
	if logoAsset then
		return new("ImageLabel", { BackgroundTransparency = 1, AnchorPoint = anchor or Vector2.zero, Position = position, Size = UDim2.fromOffset(size, size), Image = logoAsset, ScaleType = Enum.ScaleType.Fit }, parent)
	end

	return new("TextLabel", { BackgroundTransparency = 1, AnchorPoint = anchor or Vector2.zero, Position = position, Size = UDim2.fromOffset(size, size), Font = Enum.Font.GothamBlack, TextSize = size * 0.8, TextColor3 = THEME.accent, Text = "✦" }, parent)
end

for _, child in ipairs(guiParent:GetChildren()) do
	if child.Name == "VexoraUI" or child.Name == "VexoraCham" then
		child:Destroy()
	end
end

local screenGui = new("ScreenGui", {
	Name = "VexoraUI",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, guiParent)

-- Toast notifications.
local toastHolder = new("Frame", {
	AnchorPoint = Vector2.new(1, 1),
	Position = UDim2.new(1, -18, 1, -18),
	Size = UDim2.fromOffset(280, 320),
	BackgroundTransparency = 1,
	ZIndex = 100,
}, screenGui)

new("UIListLayout", {
	Padding = UDim.new(0, 8),
	VerticalAlignment = Enum.VerticalAlignment.Bottom,
	HorizontalAlignment = Enum.HorizontalAlignment.Right,
	SortOrder = Enum.SortOrder.LayoutOrder,
}, toastHolder)

---Show a small animated toast in the corner.
local function notify(title, text, color)
	local toast = new("CanvasGroup", { Size = UDim2.fromOffset(264, 56), BackgroundColor3 = THEME.bg, BorderSizePixel = 0, GroupTransparency = 1 }, toastHolder)
	corner(toast, 10)
	stroke(toast, color or THEME.accent, 1, 0.35)
	new("Frame", { Size = UDim2.new(0, 3, 1, 0), BackgroundColor3 = color or THEME.accent, BorderSizePixel = 0 }, toast)

	new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 7), Size = UDim2.new(1, -20, 0, 18), Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = THEME.text, Text = title }, toast)
	new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 26), Size = UDim2.new(1, -20, 0, 22), Font = Enum.Font.Gotham, TextSize = 11, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextColor3 = THEME.subtext, Text = text }, toast)

	tweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Quint), { GroupTransparency = 0 }):Play()

	task.delay(3.5, function()
		local fade = tweenService:Create(toast, TweenInfo.new(0.3), { GroupTransparency = 1 })
		fade:Play()
		fade.Completed:Wait()
		toast:Destroy()
	end)
end

--------------------------------------------------------------------------------
-- Key system
--------------------------------------------------------------------------------

---Check a key against the local list and the optional remote list.
---@param key string
---@return boolean
local function checkKey(key)
	local trimmed = key:match("^%s*(.-)%s*$")
	if trimmed == "" then
		return false
	end

	for _, valid in ipairs(VALID_KEYS) do
		if trimmed == valid then
			return true
		end
	end

	if KEY_URL ~= "" then
		local ok, response = pcall(request, { Url = KEY_URL, Method = "GET" })

		if ok and response and response.Success then
			for line in string.gmatch(response.Body, "[^\r\n]+") do
				if line:match("^%s*(.-)%s*$") == trimmed then
					return true
				end
			end
		end
	end

	return false
end

local function makeKeyButton(parent, text, position, size, primary)
	local button = new("TextButton", {
		Position = position,
		Size = size,
		BackgroundColor3 = primary and rgb(255, 255, 255) or THEME.row,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = THEME.text,
		Text = text,
	}, parent)
	corner(button, 8)

	if primary then
		gradient(button, { THEME.accent, THEME.accent3 }, 0)
	else
		stroke(button, THEME.line, 1, 0.4)
		button.MouseEnter:Connect(function()
			tweenService:Create(button, TweenInfo.new(0.15), { BackgroundColor3 = THEME.rowHover }):Play()
		end)
		button.MouseLeave:Connect(function()
			tweenService:Create(button, TweenInfo.new(0.15), { BackgroundColor3 = THEME.row }):Play()
		end)
	end

	return button
end

---Show the key window and yield until it resolves.
---@return boolean?
local function runKeySystem()
	local result = nil

	local backdrop = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = rgb(0, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0 }, screenGui)
	tweenService:Create(backdrop, TweenInfo.new(0.4), { BackgroundTransparency = 0.45 }):Play()

	local card = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(380, 396), BackgroundColor3 = THEME.bg, BorderSizePixel = 0 }, backdrop)
	corner(card, 14)
	glowStroke(card)

	local cardScale = new("UIScale", { Scale = 0.85 }, card)
	local viewport = workspace.CurrentCamera.ViewportSize
	local fit = math.min(1, (viewport.X - 24) / 380, (viewport.Y - 24) / 396)
	tweenService:Create(cardScale, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = fit }):Play()

	makeLogo(card, 120, UDim2.new(0.5, 0, 0, 12), Vector2.new(0.5, 0))

	new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 134), Size = UDim2.new(1, 0, 0, 28), Font = Enum.Font.GothamBlack, TextSize = 22, RichText = true, TextColor3 = THEME.text, Text = '<font color="#ff3c82"><u>vexora</u></font>.scripts' }, card)
	new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 162), Size = UDim2.new(1, 0, 0, 18), Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = THEME.subtext, Text = "enter your key to unlock the script" }, card)

	local inputHolder = new("Frame", { Position = UDim2.fromOffset(30, 194), Size = UDim2.new(1, -60, 0, 42), BackgroundColor3 = THEME.side, BorderSizePixel = 0 }, card)
	corner(inputHolder, 8)
	local inputStroke = stroke(inputHolder, THEME.line, 1, 0.3)

	local keyBox = new("TextBox", { BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -28, 1, 0), Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = THEME.text, PlaceholderText = "enter key here...", PlaceholderColor3 = THEME.subtext, Text = "", ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left }, inputHolder)

	local verifyButton = makeKeyButton(card, "Verify Key", UDim2.fromOffset(30, 250), UDim2.new(1, -60, 0, 40), true)
	local getKeyButton = makeKeyButton(card, "Get Key  •  Discord", UDim2.fromOffset(30, 298), UDim2.new(1, -60, 0, 36), false)

	local status = new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 348), Size = UDim2.new(1, 0, 0, 18), Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = THEME.subtext, Text = "join our discord to get a free key" }, card)
	local closeKey = new("TextButton", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 10), Size = UDim2.fromOffset(26, 26), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = THEME.subtext, Text = "✕" }, card)

	local busy = false

	local function verify()
		if busy then
			return
		end

		busy = true
		status.TextColor3 = THEME.subtext
		status.Text = "verifying key..."
		task.wait(0.5)

		if checkKey(keyBox.Text) then
			status.TextColor3 = THEME.good
			status.Text = "key verified. welcome!"
			inputStroke.Color = THEME.good

			if writefile then
				pcall(function()
					if makefolder and not isfolder("Vexora") then
						makefolder("Vexora")
					end

					writefile(KEY_FILE, keyBox.Text:match("^%s*(.-)%s*$"))
				end)
			end

			task.wait(0.6)
			tweenService:Create(backdrop, TweenInfo.new(0.35), { BackgroundTransparency = 1 }):Play()
			tweenService:Create(cardScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Scale = 0.6 }):Play()
			task.wait(0.35)
			result = true
			return
		end

		status.TextColor3 = THEME.bad
		status.Text = "invalid key. use get key to join the discord."
		inputStroke.Color = THEME.bad

		for _, offset in ipairs({ -9, 9, -6, 6, 0 }) do
			card.Position = UDim2.new(0.5, offset, 0.5, 0)
			task.wait(0.035)
		end

		task.wait(0.8)
		inputStroke.Color = THEME.line
		busy = false
	end

	verifyButton.MouseButton1Click:Connect(verify)
	keyBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			verify()
		end
	end)

	getKeyButton.MouseButton1Click:Connect(function()
		if setclipboard then
			pcall(setclipboard, DISCORD_LINK)
		end

		status.TextColor3 = THEME.accent2
		status.Text = "discord invite copied to clipboard!"
		notify("Get Key", "Paste " .. DISCORD_LINK .. " in your browser.", THEME.accent2)
	end)

	closeKey.MouseButton1Click:Connect(function()
		result = false
	end)

	-- Auto-login with a saved key.
	if isfile and readfile and isfile(KEY_FILE) then
		local ok, savedKey = pcall(readfile, KEY_FILE)

		if ok and savedKey and checkKey(savedKey) then
			keyBox.Text = savedKey
			task.spawn(verify)
		end
	end

	while result == nil and screenGui.Parent do
		task.wait(0.1)
	end

	backdrop:Destroy()
	return result
end

if not runKeySystem() then
	screenGui:Destroy()
	return
end

--------------------------------------------------------------------------------
-- Config
--------------------------------------------------------------------------------

local Config = {
	combat = {
		aimbot = false,
		aimMethod = "Camera",
		aimKey = isMobile and "Always On" or "Right Mouse",
		aimPart = "Head",
		smoothing = 70,
		stickyTarget = true,
		fov = 160,
		showFov = true,
		fovColor = rgb(255, 60, 130),
		fovColorB = rgb(255, 190, 90),
		fovColorMode = "Pulse",
		fovFill = true,
		fovFillColor = rgb(255, 150, 205),
		fovFillMode = "Pastel",
		fovFillOpacity = 0.28,
		teamCheck = true,
		wallCheck = true,
		prediction = false,
		predictionAmount = 0.12,

		silentAim = false,
		silentPart = "Head",
		silentRandom = false,
		silentFov = 250,
		showSilentFov = true,
		silentFovColor = rgb(255, 90, 90),
		silentFovMode = "Static",
		hitChance = 100,
		silentWallCheck = false,
		remoteRedirect = false,

		triggerbot = false,
		triggerDelay = 40,
		triggerHeadOnly = false,

		autoShoot = false,
		autoShootDelay = 80,
		autoShootFov = 60,
		autoShootWallCheck = true,

		hitbox = false,
		hitboxPart = "Head",
		hitboxSize = 6,
		hitboxTransparency = 0.6,
	},
	esp = {
		enabled = false,
		boxes = true,
		names = true,
		distance = true,
		health = true,
		tracers = false,
		tracerOrigin = "Bottom",
		chams = false,
		chamsFill = 0.6,
		teamCheck = true,
		maxDistance = 1500,
		color = rgb(255, 60, 130),
		rainbow = false,
	},
	world = {
		environment = "Default",
		autoWeather = true,
		transition = 2.5,
		weather = "None",
		intensity = 100,
		particleSize = 100,
		fallSpeed = 100,
		windStrength = 3,
		windDirection = 45,
		radius = 70,
		height = 45,
		nearPetals = true,
		lightning = false,
		fogDensity = 0.75,
		fogBlur = 8,
		timeLock = false,
		timeOfDay = 14,
		fullbright = false,
		noFog = false,
		noShadows = false,
		skyMode = "Match Environment",
		skyId = "",
		sunSize = 21,
		moonSize = 11,
		effectPreset = "None",
		dof = false,
		dofFocus = 60,
		dofRadius = 40,
		dofFar = 0.35,
		dofNear = 0.1,
		vignette = false,
		vignetteOpacity = 0.55,
		vignetteSize = 0.35,
		vignetteColor = rgb(40, 0, 25),
		filter = false,
		filterColor = rgb(255, 120, 190),
		filterOpacity = 0.9,
		rainbowTint = false,
		rainbowTintSpeed = 0.15,
		softShadows = false,
		shadowSoftness = 0.2,
		live = {},
	},
	misc = {
		hud = true,
		speed = false,
		speedAmount = 8,
		fly = false,
		flySpeed = 60,
		infiniteJump = false,
		noclip = false,
		walkSpeed = false,
		walkSpeedValue = 32,
		jumpPower = false,
		jumpPowerValue = 80,
		gravity = false,
		gravityValue = 80,
		bhop = false,
		spinbot = false,
		spinSpeed = 20,
		clickTp = false,
		maxZoom = false,
		maxZoomValue = 500,
		autoClicker = false,
		autoClickerCps = 12,
		customFov = false,
		fieldOfView = 90,
		fpsCap = false,
		fpsCapValue = 144,
		antiAfk = true,
		noLag = false,
		crosshair = true,
		crosshairStyle = "Classic",
		crosshairCross = true,
		crosshairRing = true,
		crosshairFill = true,
		crosshairDot = false,
		crosshairRadius = 12,
		crosshairSize = 5,
		crosshairGap = 3,
		crosshairThickness = 1.5,
		crosshairRingThickness = 1.5,
		crosshairRotation = 20,
		crosshairDotSize = 1.5,
		crosshairSpin = false,
		crosshairSpinSpeed = 90,
		crosshairColor = rgb(255, 255, 255),
		crosshairColorB = rgb(255, 60, 130),
		crosshairColorMode = "Pulse",
		crosshairRingColor = rgb(255, 160, 205),
		crosshairRingMode = "Rainbow",
		crosshairFillColor = rgb(255, 120, 190),
		crosshairFillMode = "Pastel",
		crosshairFillOpacity = 0.35,
		mobileButton = userInputService.TouchEnabled,
		menuKey = "RightShift",
	},
}

Vexora.config = Config

---Resolve an animated color for a mode (Static, Rainbow, Pulse, Pastel).
local function modeColor(mode, base, second, offset)
	local now = os.clock()
	offset = offset or 0

	if mode == "Rainbow" then
		return Color3.fromHSV((now * 0.3 + offset) % 1, 0.75, 1)
	elseif mode == "Pastel" then
		return Color3.fromHSV((now * 0.2 + offset) % 1, 0.38, 1)
	elseif mode == "Pulse" then
		return base:Lerp(second or rgb(255, 255, 255), (math.sin(now * 2.2 + offset * 6) + 1) / 2)
	end

	return base
end

---Resolve a color, switching to the animated rainbow when requested.
local function resolveColor(color, rainbow)
	if rainbow then
		return Color3.fromHSV((os.clock() * 0.3) % 1, 0.75, 1)
	end

	return color
end

local function createDrawing(className, properties)
	local drawing = Drawing.new(className)
	drawing.Transparency = DRAWING_OPAQUE

	for key, value in pairs(properties) do
		drawing[key] = value
	end

	return drawing
end

local function trackDrawing(drawing)
	table.insert(Vexora.drawings, drawing)
	return drawing
end

--------------------------------------------------------------------------------
-- Targeting utilities (players and bots)
--------------------------------------------------------------------------------

local function isEnemy(player, teamCheck)
	if not player or not teamCheck then
		return true
	end

	if player.Team == nil or localPlayer.Team == nil then
		return true
	end

	return player.Team ~= localPlayer.Team
end

---Resolve a body part with R6/R15 fallbacks so bots without a full rig still work.
local function resolvePart(character, partName)
	local part

	if partName == "Torso" then
		part = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
	else
		part = character:FindFirstChild(partName)
	end

	return part or character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart or character:FindFirstChildWhichIsA("BasePart")
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true

---Line-of-sight check from the camera to a part.
local function isVisible(part)
	local ignore = { currentCamera }
	if localPlayer.Character then
		table.insert(ignore, localPlayer.Character)
	end

	rayParams.FilterDescendantsInstances = ignore

	local origin = currentCamera.CFrame.Position
	local result = workspace:Raycast(origin, part.Position - origin, rayParams)

	return result == nil or result.Instance:IsDescendantOf(part.Parent)
end

local function predictPosition(part)
	local combat = Config.combat
	if not combat.prediction then
		return part.Position
	end

	return part.Position + part.AssemblyLinearVelocity * combat.predictionAmount
end

---Aim origin: the cursor on PC, the screen center on touch-only devices.
local function getAimOrigin()
	if isMobile then
		return currentCamera.ViewportSize / 2
	end

	return userInputService:GetMouseLocation()
end

-- Every Model with a Humanoid is a target: real players and NPC bots alike.
local Targets = { set = {} }

function Targets.playerOf(model)
	return playersService:GetPlayerFromCharacter(model)
end

function Targets.add(model)
	if Targets.set[model] or Targets.playerOf(model) == localPlayer then
		return
	end

	if not model:FindFirstChildOfClass("Humanoid") then
		return
	end

	Targets.set[model] = model.AncestryChanged:Connect(function()
		if not model:IsDescendantOf(workspace) then
			Targets.remove(model)
		end
	end)

	Targets.onAdded(model)
end

function Targets.remove(model)
	local connection = Targets.set[model]
	if not connection then
		return
	end

	connection:Disconnect()
	Targets.set[model] = nil
	Targets.onRemoved(model)
end

local function considerInstance(instance)
	if instance:IsA("Humanoid") and instance.Parent and instance.Parent:IsA("Model") then
		Targets.add(instance.Parent)
	end
end

---Track targets via the initial scan, DescendantAdded and a slow rescan.
function Targets.start()
	connect(workspace.DescendantAdded, considerInstance)

	task.spawn(function()
		while Vexora.active do
			for index, instance in ipairs(workspace:GetDescendants()) do
				considerInstance(instance)

				if index % 1000 == 0 then
					task.wait()
				end
			end

			task.wait(8)
		end
	end)
end

function Targets.stop()
	for model in pairs(Targets.set) do
		Targets.remove(model)
	end
end

Targets.onAdded = function() end
Targets.onRemoved = function() end

---Return the closest enemy player or bot whose part projects nearest the aim origin within fovRadius.
---@return Model?, BasePart?, number?
local function getClosestTarget(fovRadius, partName, wallCheck)
	local candidates = {}
	local origin = getAimOrigin()

	for model in pairs(Targets.set) do
		local player = Targets.playerOf(model)
		if player and not isEnemy(player, Config.combat.teamCheck) then continue end

		local humanoid = model:FindFirstChildOfClass("Humanoid")
		local part = resolvePart(model, partName)
		if not (humanoid and part and humanoid.Health > 0) then continue end

		local screenPos, onScreen = currentCamera:WorldToViewportPoint(part.Position)
		if not onScreen then continue end

		local dist = (Vector2.new(screenPos.X, screenPos.Y) - origin).Magnitude
		if dist <= fovRadius then
			table.insert(candidates, { model = model, part = part, dist = dist })
		end
	end

	table.sort(candidates, function(a, b)
		return a.dist < b.dist
	end)

	for _, info in ipairs(candidates) do
		if not wallCheck or isVisible(info.part) then
			return info.model, info.part, info.dist
		end
	end

	return nil, nil, nil
end

local function isAimKeyDown()
	if userInputService:GetFocusedTextBox() then
		return false
	end

	local keyName = Config.combat.aimKey
	if keyName == "Always On" then
		return true
	end

	local bind = AIM_KEYS[keyName]
	if not bind then
		return false
	end

	if bind.EnumType == Enum.UserInputType then
		return userInputService:IsMouseButtonPressed(bind)
	end

	return userInputService:IsKeyDown(bind)
end

local function clickMouse()
	if mouse1click and isrbxactive and isrbxactive() then
		mouse1click()
		return
	end

	pcall(function()
		virtualUser:ClickButton1(getAimOrigin())
	end)
end

--------------------------------------------------------------------------------
-- Silent aim hooks (installed once, driven by shared.Vexora)
--------------------------------------------------------------------------------

if not shared.VexoraHooked then
	shared.VexoraHooked = true

	local oldNamecall
	oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
		local method = getnamecallmethod()
		local state = shared.Vexora
		local silent = state and state.silent

		if silent and silent.part and silent.roll and not checkcaller() then
			if self == workspace then
				if method == "Raycast" then
					local args = table.pack(...)
					local origin, direction = args[1], args[2]

					if typeof(origin) == "Vector3" and typeof(direction) == "Vector3" then
						local toTarget = silent.position - origin
						args[2] = toTarget.Unit * math.max(direction.Magnitude, toTarget.Magnitude + 5)
						return oldNamecall(self, table.unpack(args, 1, args.n))
					end
				elseif method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist" then
					local args = table.pack(...)
					local ray = args[1]

					if typeof(ray) == "Ray" then
						local toTarget = silent.position - ray.Origin
						args[1] = Ray.new(ray.Origin, toTarget.Unit * math.max(ray.Direction.Magnitude, toTarget.Magnitude + 5))
						return oldNamecall(self, table.unpack(args, 1, args.n))
					end
				end
			elseif (method == "FireServer" or method == "InvokeServer") and state.config.combat.remoteRedirect then
				local args = table.pack(...)
				local changed = false

				for index = 1, args.n do
					local value = args[index]

					if typeof(value) == "Instance" and value:IsA("BasePart") then
						local model = value:FindFirstAncestorOfClass("Model")

						if model and model ~= localPlayer.Character and model:FindFirstChildOfClass("Humanoid") then
							args[index] = silent.part
							changed = true
						end
					end
				end

				-- Nested calls can clobber the namecall method, so restore it.
				setnamecallmethod(method)

				if changed then
					return oldNamecall(self, table.unpack(args, 1, args.n))
				end
			end
		end

		return oldNamecall(self, ...)
	end))

	local oldIndex
	oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
		local state = shared.Vexora
		local silent = state and state.silent

		if silent and silent.part and silent.roll and self == state.mouse and not checkcaller() then
			if key == "Hit" then
				return CFrame.new(silent.position)
			elseif key == "Target" then
				return silent.part
			end
		end

		return oldIndex(self, key)
	end))
end

--------------------------------------------------------------------------------
-- Combat
--------------------------------------------------------------------------------

local Combat = { aimLock = nil, remainder = Vector2.new(0, 0), triggerSeenAt = nil, autoShootSeenAt = nil }

local aimFovFill = trackDrawing(createDrawing("Circle", { Thickness = 1, NumSides = 90, Filled = true, Visible = false }))
local aimFovCircle = trackDrawing(createDrawing("Circle", { Thickness = 1, NumSides = 72, Filled = false, Visible = false }))
local silentFovCircle = trackDrawing(createDrawing("Circle", { Thickness = 1, NumSides = 72, Filled = false, Visible = false }))

---Draw the fov circles with animated colors.
function Combat.updateFovCircles()
	local combat = Config.combat
	local origin = getAimOrigin()

	aimFovFill.Visible = combat.aimbot and combat.fovFill
	aimFovFill.Position = origin
	aimFovFill.Radius = combat.fov
	aimFovFill.Color = modeColor(combat.fovFillMode, combat.fovFillColor, combat.fovColorB, 0.25)
	aimFovFill.Transparency = combat.fovFillOpacity

	aimFovCircle.Visible = combat.aimbot and combat.showFov
	aimFovCircle.Position = origin
	aimFovCircle.Radius = combat.fov
	aimFovCircle.Color = modeColor(combat.fovColorMode, combat.fovColor, combat.fovColorB, 0)

	silentFovCircle.Visible = combat.silentAim and combat.showSilentFov
	silentFovCircle.Position = origin
	silentFovCircle.Radius = combat.silentFov
	silentFovCircle.Color = modeColor(combat.silentFovMode, combat.silentFovColor, combat.fovColorB, 0.5)
end

---Keep the current lock while it stays valid so the aim never jitters between targets.
local function getLockedPart(combat)
	local character = Combat.aimLock
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local part = character and resolvePart(character, combat.aimPart)
	if not (humanoid and part and humanoid.Health > 0 and character:IsDescendantOf(workspace)) then
		return nil
	end

	local screenPos, onScreen = currentCamera:WorldToViewportPoint(part.Position)
	if not onScreen then
		return nil
	end

	local dist = (Vector2.new(screenPos.X, screenPos.Y) - getAimOrigin()).Magnitude
	if dist > combat.fov * 1.6 then
		return nil
	end

	if combat.wallCheck and not isVisible(part) then
		return nil
	end

	return part
end

---Smoothly pull the camera or mouse toward the target (runs after the default camera each frame).
function Combat.updateAimbot(deltaTime)
	local combat = Config.combat
	if not combat.aimbot or not isAimKeyDown() then
		Combat.aimLock = nil
		Combat.remainder = Vector2.new(0, 0)
		return
	end

	local part = combat.stickyTarget and getLockedPart(combat) or nil
	if not part then
		local model, closestPart = getClosestTarget(combat.fov, combat.aimPart, combat.wallCheck)
		Combat.aimLock = model
		part = closestPart
	end

	if not part then
		return
	end

	local position = predictPosition(part)

	-- Exponential smoothing: 0 is instant, 100 is very slow and soft.
	local factor = 1 - combat.smoothing / 100
	local speed = 1.2 + 45 * factor * factor
	local alpha = combat.smoothing <= 0 and 1 or (1 - math.exp(-speed * deltaTime))

	if combat.aimMethod == "Mouse" and not isMobile and mousemoverel then
		if not isrbxactive() then
			return
		end

		local screenPos, onScreen = currentCamera:WorldToViewportPoint(position)
		if not onScreen then
			return
		end

		local mousePos = userInputService:GetMouseLocation()
		local delta = Vector2.new(screenPos.X - mousePos.X, screenPos.Y - mousePos.Y) * alpha + Combat.remainder
		local moveX = delta.X >= 0 and math.floor(delta.X) or math.ceil(delta.X)
		local moveY = delta.Y >= 0 and math.floor(delta.Y) or math.ceil(delta.Y)

		Combat.remainder = delta - Vector2.new(moveX, moveY)
		mousemoverel(moveX, moveY)
		return
	end

	local goal = CFrame.lookAt(currentCamera.CFrame.Position, position)
	currentCamera.CFrame = currentCamera.CFrame:Lerp(goal, alpha)
end

---Pick the silent aim target and roll the hit chance once per shot window.
function Combat.updateSilentAim()
	local combat = Config.combat
	local silent = Vexora.silent
	local now = os.clock()

	if now - silent.rollAt >= 0.2 then
		silent.rollAt = now
		silent.roll = math.random(1, 100) <= combat.hitChance
	end

	silent.chance = combat.hitChance

	if not combat.silentAim then
		silent.part = nil
		return
	end

	local partName = combat.silentPart

	if combat.silentRandom then
		if now - silent.partAt >= 0.2 or not silent.partName then
			silent.partAt = now
			silent.partName = PART_NAMES[math.random(#PART_NAMES)]
		end

		partName = silent.partName
	end

	local _, part = getClosestTarget(combat.silentFov, partName, combat.silentWallCheck)
	if not part then
		silent.part = nil
		return
	end

	silent.part = part
	silent.position = predictPosition(part)
end

function Combat.updateTriggerbot()
	local combat = Config.combat
	if not combat.triggerbot then
		Combat.triggerSeenAt = nil
		return
	end

	local target = mouse.Target
	local character = target

	while character and not character:FindFirstChildOfClass("Humanoid") do
		character = character.Parent
	end

	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local player = character and Targets.playerOf(character)

	local valid = humanoid and humanoid.Health > 0 and player ~= localPlayer and (not player or isEnemy(player, combat.teamCheck))
	if valid and combat.triggerHeadOnly and target.Name ~= "Head" then
		valid = false
	end

	if not valid then
		Combat.triggerSeenAt = nil
		return
	end

	Combat.triggerSeenAt = Combat.triggerSeenAt or os.clock()
	if os.clock() - Combat.triggerSeenAt >= combat.triggerDelay / 1000 then
		clickMouse()
		Combat.triggerSeenAt = os.clock() + 0.12
	end
end

function Combat.updateAutoShoot()
	local combat = Config.combat
	if not combat.autoShoot then
		Combat.autoShootSeenAt = nil
		return
	end

	local model = getClosestTarget(combat.autoShootFov, combat.silentPart, combat.autoShootWallCheck)
	if not model then
		Combat.autoShootSeenAt = nil
		return
	end

	Combat.autoShootSeenAt = Combat.autoShootSeenAt or os.clock()
	if os.clock() - Combat.autoShootSeenAt >= combat.autoShootDelay / 1000 then
		clickMouse()
		Combat.autoShootSeenAt = os.clock() + 0.1
	end
end

function Combat.restoreHitbox(part)
	local cache = Vexora.hitboxCache[part]
	if cache and part.Parent then
		part.Size = cache.size
		part.Transparency = cache.transparency
		part.CanCollide = cache.canCollide
	end

	Vexora.hitboxCache[part] = nil
end

---Expand enemy hitboxes (client side) and restore them when disabled.
function Combat.updateHitboxes()
	local combat = Config.combat
	local active = {}

	if not combat.hitbox and next(Vexora.hitboxCache) == nil then
		return
	end

	if combat.hitbox then
		local size = Vector3.new(combat.hitboxSize, combat.hitboxSize, combat.hitboxSize)

		for model in pairs(Targets.set) do
			local player = Targets.playerOf(model)
			if player and not isEnemy(player, combat.teamCheck) then continue end

			local humanoid = model:FindFirstChildOfClass("Humanoid")
			local part = resolvePart(model, combat.hitboxPart)
			if not (humanoid and part and humanoid.Health > 0) then continue end

			if not Vexora.hitboxCache[part] then
				Vexora.hitboxCache[part] = { size = part.Size, transparency = part.Transparency, canCollide = part.CanCollide }
			end

			if part.Size ~= size then
				part.Size = size
			end

			part.Transparency = combat.hitboxTransparency
			part.CanCollide = false
			active[part] = true
		end
	end

	for part in pairs(Vexora.hitboxCache) do
		if not active[part] then
			Combat.restoreHitbox(part)
		end
	end
end

--------------------------------------------------------------------------------
-- ESP
--------------------------------------------------------------------------------

local Esp = { wasActive = false }

local highlightFolder = new("Folder", { Name = "VexoraCham" }, guiParent)
table.insert(Vexora.instances, highlightFolder)

function Esp.create(model)
	if Vexora.espObjects[model] then
		return
	end

	local highlight = new("Highlight", { DepthMode = Enum.HighlightDepthMode.AlwaysOnTop, OutlineTransparency = 0, Enabled = false }, highlightFolder)

	Vexora.espObjects[model] = {
		boxOutline = createDrawing("Square", { Thickness = 3, Filled = false, Color = Color3.new(0, 0, 0), Visible = false }),
		box = createDrawing("Square", { Thickness = 1, Filled = false, Visible = false }),
		name = createDrawing("Text", { Size = 13, Center = true, Outline = true, Font = Drawing.Fonts.UI, Visible = false }),
		distance = createDrawing("Text", { Size = 12, Center = true, Outline = true, Font = Drawing.Fonts.UI, Visible = false }),
		healthBack = createDrawing("Line", { Thickness = 3, Color = Color3.new(0, 0, 0), Visible = false }),
		healthBar = createDrawing("Line", { Thickness = 1.5, Visible = false }),
		tracer = createDrawing("Line", { Thickness = 1, Visible = false }),
		highlight = highlight,
	}
end

function Esp.hide(set)
	for key, object in pairs(set) do
		if key ~= "highlight" then
			object.Visible = false
		end
	end

	set.highlight.Enabled = false
end

function Esp.remove(model)
	local set = Vexora.espObjects[model]
	if not set then
		return
	end

	for key, object in pairs(set) do
		if key == "highlight" then
			object:Destroy()
		else
			pcall(function()
				object:Remove()
			end)
		end
	end

	Vexora.espObjects[model] = nil
end

function Esp.update()
	local esp = Config.esp

	if not esp.enabled then
		if Esp.wasActive then
			Esp.wasActive = false

			for _, set in pairs(Vexora.espObjects) do
				Esp.hide(set)
			end
		end

		return
	end

	Esp.wasActive = true

	local cameraPosition = currentCamera.CFrame.Position
	local viewport = currentCamera.ViewportSize
	local baseColor = resolveColor(esp.color, esp.rainbow)

	for character, set in pairs(Vexora.espObjects) do
		local player = Targets.playerOf(character)
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local root = resolvePart(character, "HumanoidRootPart")
		local head = character:FindFirstChild("Head") or root

		local valid = humanoid and root and head and humanoid.Health > 0
		if valid and esp.teamCheck and not isEnemy(player, true) then
			valid = false
		end

		local distance = valid and (cameraPosition - root.Position).Magnitude or 0
		if valid and distance > esp.maxDistance then
			valid = false
		end

		if not valid then
			Esp.hide(set)
			continue
		end

		local drawColor = isEnemy(player, true) and baseColor or THEME.good

		set.highlight.Adornee = character
		set.highlight.FillColor = drawColor
		set.highlight.OutlineColor = drawColor
		set.highlight.FillTransparency = esp.chamsFill
		set.highlight.Enabled = esp.chams

		local rootPos, onScreen = currentCamera:WorldToViewportPoint(root.Position)
		if not onScreen then
			for key, object in pairs(set) do
				if key ~= "highlight" then
					object.Visible = false
				end
			end

			continue
		end

		local topPos = currentCamera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.9, 0))
		local bottomPos = currentCamera:WorldToViewportPoint(root.Position - Vector3.new(0, 3.1, 0))
		local height = math.abs(bottomPos.Y - topPos.Y)
		local width = height * 0.55
		local boxPosition = Vector2.new(rootPos.X - width / 2, topPos.Y)
		local boxSize = Vector2.new(width, height)

		set.boxOutline.Visible = esp.boxes
		set.boxOutline.Position = boxPosition
		set.boxOutline.Size = boxSize

		set.box.Visible = esp.boxes
		set.box.Position = boxPosition
		set.box.Size = boxSize
		set.box.Color = drawColor

		set.name.Visible = esp.names
		set.name.Text = player and player.DisplayName or character.Name
		set.name.Position = Vector2.new(rootPos.X, boxPosition.Y - 16)
		set.name.Color = Color3.new(1, 1, 1)

		set.distance.Visible = esp.distance
		set.distance.Text = string.format("%dm", math.floor(distance))
		set.distance.Position = Vector2.new(rootPos.X, boxPosition.Y + height + 2)
		set.distance.Color = rgb(210, 210, 220)

		local ratio = math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1)
		local barX = boxPosition.X - 5

		set.healthBack.Visible = esp.health
		set.healthBack.From = Vector2.new(barX, boxPosition.Y + height + 1)
		set.healthBack.To = Vector2.new(barX, boxPosition.Y - 1)

		set.healthBar.Visible = esp.health
		set.healthBar.From = Vector2.new(barX, boxPosition.Y + height)
		set.healthBar.To = Vector2.new(barX, boxPosition.Y + height - height * ratio)
		set.healthBar.Color = Color3.fromHSV(ratio * 0.33, 1, 1)

		local origin
		if esp.tracerOrigin == "Center" then
			origin = viewport / 2
		elseif esp.tracerOrigin == "Mouse" then
			origin = getAimOrigin()
		else
			origin = Vector2.new(viewport.X / 2, viewport.Y)
		end

		set.tracer.Visible = esp.tracers
		set.tracer.From = origin
		set.tracer.To = Vector2.new(rootPos.X, bottomPos.Y)
		set.tracer.Color = drawColor
	end
end

--------------------------------------------------------------------------------
-- World: instances and live values
--------------------------------------------------------------------------------

local World = { tweens = {} }
local Weather = { part = nil, near = nil, entries = {}, preset = nil }
local Effects = {}
Vexora.refreshUi = function() end

local originalLighting = {
	ClockTime = lighting.ClockTime,
	Brightness = lighting.Brightness,
	Ambient = lighting.Ambient,
	OutdoorAmbient = lighting.OutdoorAmbient,
	FogColor = lighting.FogColor,
	FogStart = lighting.FogStart,
	FogEnd = lighting.FogEnd,
	ColorShift_Top = lighting.ColorShift_Top,
	ColorShift_Bottom = lighting.ColorShift_Bottom,
	ExposureCompensation = lighting.ExposureCompensation,
	GlobalShadows = lighting.GlobalShadows,
	ShadowSoftness = lighting.ShadowSoftness,
}

local atmosphere = lighting:FindFirstChildOfClass("Atmosphere")
local ownsAtmosphere = false
local originalAtmosphere

if atmosphere then
	originalAtmosphere = { Density = atmosphere.Density, Offset = atmosphere.Offset, Color = atmosphere.Color, Decay = atmosphere.Decay, Glare = atmosphere.Glare, Haze = atmosphere.Haze }
else
	ownsAtmosphere = true
	originalAtmosphere = { Density = 0, Offset = 0, Color = rgb(199, 199, 199), Decay = rgb(106, 112, 125), Glare = 0, Haze = 0 }
	atmosphere = new("Atmosphere", { Name = "VexoraAtmosphere", Density = 0, Haze = 0, Glare = 0 }, lighting)
	table.insert(Vexora.instances, atmosphere)
end

local SKY_FACES = { "SkyboxBk", "SkyboxDn", "SkyboxFt", "SkyboxLf", "SkyboxRt", "SkyboxUp" }
local CLASSIC_SKY = {
	SkyboxBk = "rbxasset://textures/sky/sky512_bk.tex",
	SkyboxDn = "rbxasset://textures/sky/sky512_dn.tex",
	SkyboxFt = "rbxasset://textures/sky/sky512_ft.tex",
	SkyboxLf = "rbxasset://textures/sky/sky512_lf.tex",
	SkyboxRt = "rbxasset://textures/sky/sky512_rt.tex",
	SkyboxUp = "rbxasset://textures/sky/sky512_up.tex",
}

local sky = lighting:FindFirstChildOfClass("Sky")
local ownsSky = false
local originalSky = { faces = {} }

if sky then
	originalSky.StarCount = sky.StarCount
	originalSky.CelestialBodiesShown = sky.CelestialBodiesShown
	originalSky.SunAngularSize = sky.SunAngularSize
	originalSky.MoonAngularSize = sky.MoonAngularSize

	for _, face in ipairs(SKY_FACES) do
		originalSky.faces[face] = sky[face]
	end
else
	ownsSky = true
	originalSky.StarCount = 3000
	originalSky.CelestialBodiesShown = true
	originalSky.SunAngularSize = 21
	originalSky.MoonAngularSize = 11
	originalSky.faces = CLASSIC_SKY
	sky = new("Sky", { Name = "VexoraSky" }, lighting)
	table.insert(Vexora.instances, sky)
end

local gradeEffect = new("ColorCorrectionEffect", { Name = "VexoraGrade" }, lighting)
local bloomEffect = new("BloomEffect", { Name = "VexoraBloom", Intensity = 0, Size = 24, Threshold = 1 }, lighting)
local blurEffect = new("BlurEffect", { Name = "VexoraBlur", Size = 0 }, lighting)
local sunRays = new("SunRaysEffect", { Name = "VexoraRays", Intensity = 0, Spread = 0.6 }, lighting)
local dofEffect = new("DepthOfFieldEffect", { Name = "VexoraDof", Enabled = false, FarIntensity = 0, NearIntensity = 0, FocusDistance = 60, InFocusRadius = 40 }, lighting)
table.insert(Vexora.instances, gradeEffect)
table.insert(Vexora.instances, bloomEffect)
table.insert(Vexora.instances, blurEffect)
table.insert(Vexora.instances, sunRays)
table.insert(Vexora.instances, dofEffect)

-- Screen overlays: vignette edges and a color filter, both below the menu.
local filterFrame = new("Frame", { Name = "VexoraFilter", Size = UDim2.fromScale(1, 1), BackgroundColor3 = rgb(255, 120, 190), BackgroundTransparency = 1, BorderSizePixel = 0, Active = false, Visible = false }, screenGui)
local vignetteFrames = {}

for index, spec in ipairs({
	{ UDim2.fromScale(1, 0), UDim2.fromScale(0, 0), 90 },
	{ UDim2.fromScale(1, 0), UDim2.fromScale(0, 1), 270, Vector2.new(0, 1) },
	{ UDim2.fromScale(0, 1), UDim2.fromScale(0, 0), 0 },
	{ UDim2.fromScale(0, 1), UDim2.fromScale(1, 0), 180, Vector2.new(1, 0) },
}) do
	local frame = new("Frame", { Name = "VexoraVignette" .. index, Size = spec[1], Position = spec[2], AnchorPoint = spec[4] or Vector2.zero, BackgroundColor3 = rgb(0, 0, 0), BorderSizePixel = 0, Active = false, Visible = false }, screenGui)
	local fade = new("UIGradient", { Rotation = spec[3] }, frame)
	vignetteFrames[index] = { frame = frame, fade = fade }
end

-- Live key -> instance property. Every environment is a table of these keys.
local BINDINGS = {
	{ "t", lighting, "ClockTime" }, { "br", lighting, "Brightness" }, { "amb", lighting, "Ambient" }, { "out", lighting, "OutdoorAmbient" },
	{ "fog", lighting, "FogColor" }, { "fogStart", lighting, "FogStart" }, { "fogEnd", lighting, "FogEnd" },
	{ "top", lighting, "ColorShift_Top" }, { "bot", lighting, "ColorShift_Bottom" }, { "exp", lighting, "ExposureCompensation" },
	{ "dens", atmosphere, "Density" }, { "off", atmosphere, "Offset" }, { "acol", atmosphere, "Color" }, { "adec", atmosphere, "Decay" },
	{ "glare", atmosphere, "Glare" }, { "haze", atmosphere, "Haze" },
	{ "tint", gradeEffect, "TintColor" }, { "sat", gradeEffect, "Saturation" }, { "con", gradeEffect, "Contrast" }, { "gb", gradeEffect, "Brightness" },
	{ "bloom", bloomEffect, "Intensity" }, { "bsize", bloomEffect, "Size" }, { "bthr", bloomEffect, "Threshold" },
	{ "blur", blurEffect, "Size" }, { "rays", sunRays, "Intensity" }, { "stars", sky, "StarCount" },
}

local BASE = {
	t = 14, br = 2, amb = rgb(120, 120, 130), out = rgb(150, 150, 160), fog = rgb(190, 200, 215), fogStart = 0, fogEnd = 100000,
	top = rgb(255, 255, 255), bot = rgb(255, 255, 255), exp = 0,
	dens = 0, off = 0, acol = rgb(199, 199, 199), adec = rgb(106, 112, 125), glare = 0, haze = 0,
	tint = rgb(255, 255, 255), sat = 0, con = 0, gb = 0, bloom = 0, bsize = 24, bthr = 1, blur = 0, rays = 0,
	stars = 3000, bodies = true, weather = "None",
}

local function makeEnv(spec)
	local env = table.clone(BASE)

	for key, value in pairs(spec) do
		env[key] = value
	end

	return env
end

local ENVIRONMENTS = {
	Default = makeEnv({
		t = originalLighting.ClockTime, br = originalLighting.Brightness, amb = originalLighting.Ambient, out = originalLighting.OutdoorAmbient,
		fog = originalLighting.FogColor, fogStart = originalLighting.FogStart, fogEnd = originalLighting.FogEnd,
		top = originalLighting.ColorShift_Top, bot = originalLighting.ColorShift_Bottom, exp = originalLighting.ExposureCompensation,
		dens = originalAtmosphere.Density, off = originalAtmosphere.Offset, acol = originalAtmosphere.Color, adec = originalAtmosphere.Decay,
		glare = originalAtmosphere.Glare, haze = originalAtmosphere.Haze, stars = originalSky.StarCount, bodies = originalSky.CelestialBodiesShown,
	}),

	-- Blossom: pink sky, pink haze, pink light on every object and pink bloom over the whole world.
	Blossom = makeEnv({ t = 16.9, br = 3.2, amb = rgb(255, 140, 195), out = rgb(255, 165, 215), fog = rgb(255, 160, 210), fogEnd = 850, top = rgb(255, 105, 185), bot = rgb(255, 150, 205), exp = 0.35, dens = 0.55, off = 0.4, acol = rgb(255, 135, 200), adec = rgb(255, 60, 150), glare = 1.2, haze = 3.2, tint = rgb(255, 185, 225), sat = 0.65, con = 0.14, gb = 0.05, bloom = 1.6, bsize = 44, bthr = 0.72, rays = 0.45, stars = 0, weather = "Petals" }),
	["Pink Paradise"] = makeEnv({ t = 15.5, br = 3.4, amb = rgb(255, 170, 215), out = rgb(255, 190, 230), fog = rgb(255, 190, 228), fogEnd = 1200, top = rgb(255, 150, 215), bot = rgb(255, 120, 190), exp = 0.35, dens = 0.45, off = 0.3, acol = rgb(255, 170, 220), adec = rgb(235, 80, 170), glare = 1, haze = 2.6, tint = rgb(255, 200, 235), sat = 0.75, con = 0.1, gb = 0.06, bloom = 1.5, bsize = 42, bthr = 0.7, rays = 0.4, stars = 0, weather = "Blossom Rain" }),
	Night = makeEnv({ t = 23.5, br = 1.6, amb = rgb(45, 55, 130), out = rgb(70, 90, 190), fog = rgb(14, 18, 55), fogEnd = 1500, top = rgb(70, 100, 240), bot = rgb(30, 40, 120), exp = 0.1, dens = 0.3, off = 0.15, acol = rgb(60, 85, 190), adec = rgb(20, 28, 100), haze = 1.2, tint = rgb(190, 210, 255), sat = 0.3, con = 0.15, bloom = 1, stars = 9000 }),
	Sakura = makeEnv({ t = 17.3, br = 2.9, amb = rgb(240, 150, 185), out = rgb(255, 175, 205), fog = rgb(255, 205, 228), fogEnd = 1000, top = rgb(255, 170, 215), bot = rgb(255, 200, 225), exp = 0.25, dens = 0.4, off = 0.28, acol = rgb(255, 195, 222), adec = rgb(255, 120, 180), glare = 0.6, haze = 2.2, tint = rgb(255, 225, 240), sat = 0.5, con = 0.1, bloom = 1.1, rays = 0.3, stars = 0, weather = "Petals" }),
	Snowy = makeEnv({ t = 12, br = 2.6, amb = rgb(150, 175, 215), out = rgb(195, 220, 250), fog = rgb(215, 230, 250), fogEnd = 600, top = rgb(205, 230, 255), bot = rgb(230, 242, 255), exp = 0.3, dens = 0.42, acol = rgb(215, 232, 255), adec = rgb(170, 200, 240), haze = 2.4, tint = rgb(215, 238, 255), sat = 0.1, con = 0.08, bloom = 0.7, stars = 0, bodies = false, weather = "Snow" }),
	Storm = makeEnv({ t = 15, br = 1.4, amb = rgb(70, 80, 105), out = rgb(100, 112, 140), fog = rgb(75, 84, 105), fogEnd = 380, top = rgb(120, 145, 185), bot = rgb(85, 100, 130), dens = 0.55, acol = rgb(105, 120, 150), adec = rgb(60, 75, 105), haze = 3.2, tint = rgb(185, 205, 235), sat = -0.05, con = 0.22, bloom = 0.35, stars = 0, bodies = false, weather = "Heavy Rain" }),
	Sunset = makeEnv({ t = 18.1, br = 3, amb = rgb(185, 95, 75), out = rgb(255, 140, 90), fog = rgb(255, 160, 105), fogEnd = 1800, top = rgb(255, 170, 95), bot = rgb(255, 100, 65), exp = 0.3, dens = 0.34, off = 0.3, acol = rgb(255, 165, 100), adec = rgb(255, 80, 50), glare = 1, haze = 1.6, tint = rgb(255, 215, 185), sat = 0.6, con = 0.14, bloom = 1.3, rays = 0.4, stars = 0 }),
	Dawn = makeEnv({ t = 6.1, br = 2.7, amb = rgb(190, 120, 155), out = rgb(255, 180, 160), fog = rgb(255, 195, 170), fogEnd = 1400, top = rgb(255, 200, 145), bot = rgb(255, 140, 170), exp = 0.2, dens = 0.38, off = 0.25, acol = rgb(255, 190, 165), adec = rgb(245, 100, 130), glare = 0.8, haze = 1.7, tint = rgb(255, 225, 210), sat = 0.55, con = 0.1, bloom = 1.1, rays = 0.35, stars = 600 }),
	Midnight = makeEnv({ t = 0, br = 1.1, amb = rgb(30, 40, 95), out = rgb(55, 75, 160), fog = rgb(12, 16, 45), fogEnd = 900, top = rgb(90, 115, 250), bot = rgb(40, 50, 150), dens = 0.32, acol = rgb(60, 85, 190), adec = rgb(25, 35, 115), haze = 1.2, tint = rgb(185, 205, 255), sat = 0.3, con = 0.12, bloom = 0.9, stars = 12000, weather = "Fireflies" }),
	Synthwave = makeEnv({ t = 19.5, br = 2.5, amb = rgb(165, 45, 215), out = rgb(255, 60, 220), fog = rgb(115, 20, 175), fogEnd = 1000, top = rgb(255, 80, 240), bot = rgb(70, 40, 255), exp = 0.2, dens = 0.4, acol = rgb(215, 60, 255), adec = rgb(255, 50, 175), glare = 0.9, haze = 2, tint = rgb(255, 195, 255), sat = 0.9, con = 0.22, bloom = 1.8, bsize = 44, bthr = 0.65, rays = 0.25, stars = 4500 }),
	Inferno = makeEnv({ t = 17, br = 2.3, amb = rgb(175, 55, 25), out = rgb(250, 90, 40), fog = rgb(150, 40, 15), fogEnd = 700, top = rgb(255, 125, 55), bot = rgb(255, 55, 15), exp = 0.2, dens = 0.45, acol = rgb(240, 85, 40), adec = rgb(150, 35, 15), glare = 0.6, haze = 2.8, tint = rgb(255, 205, 175), sat = 0.5, con = 0.28, bloom = 1.4, stars = 0, bodies = false, weather = "Embers" }),
	Aurora = makeEnv({ t = 22, br = 1.9, amb = rgb(30, 125, 130), out = rgb(55, 185, 190), fog = rgb(12, 55, 80), fogEnd = 1400, top = rgb(80, 255, 190), bot = rgb(120, 70, 255), exp = 0.1, dens = 0.32, acol = rgb(60, 250, 190), adec = rgb(120, 60, 245), haze = 1.5, tint = rgb(195, 255, 235), sat = 0.7, con = 0.14, bloom = 1.4, stars = 10000, weather = "Snow" }),
	Desert = makeEnv({ t = 13, br = 3.4, amb = rgb(205, 150, 95), out = rgb(255, 210, 140), fog = rgb(250, 205, 145), fogEnd = 1800, top = rgb(255, 220, 150), bot = rgb(255, 190, 115), exp = 0.2, dens = 0.32, off = 0.1, acol = rgb(250, 200, 140), adec = rgb(230, 150, 85), glare = 0.8, haze = 2.6, tint = rgb(255, 230, 195), sat = 0.4, con = 0.14, bloom = 0.9, rays = 0.25, stars = 0 }),
	["Deep Sea"] = makeEnv({ t = 14, br = 2, amb = rgb(25, 115, 175), out = rgb(50, 160, 225), fog = rgb(15, 95, 150), fogEnd = 420, top = rgb(80, 205, 255), bot = rgb(15, 80, 165), dens = 0.5, acol = rgb(75, 190, 240), adec = rgb(15, 95, 165), haze = 2.8, tint = rgb(185, 235, 255), sat = 0.5, con = 0.1, bloom = 0.8, blur = 2, stars = 0, bodies = false }),

	["Cherry Moonlight"] = makeEnv({ t = 21.5, br = 1.9, amb = rgb(135, 55, 135), out = rgb(205, 95, 190), fog = rgb(80, 22, 80), fogEnd = 1300, top = rgb(255, 125, 220), bot = rgb(130, 55, 205), dens = 0.36, acol = rgb(255, 135, 210), adec = rgb(130, 35, 165), haze = 1.8, tint = rgb(255, 205, 245), sat = 0.6, con = 0.12, bloom = 1.5, stars = 7000, moon = 22, weather = "Petals" }),
	["Neon Tokyo"] = makeEnv({ t = 22, br = 2.3, amb = rgb(75, 35, 155), out = rgb(130, 55, 245), fog = rgb(40, 8, 95), fogEnd = 900, top = rgb(0, 255, 255), bot = rgb(255, 0, 205), exp = 0.1, dens = 0.42, acol = rgb(155, 55, 255), adec = rgb(255, 35, 195), haze = 2.2, tint = rgb(225, 205, 255), sat = 1, con = 0.22, bloom = 2, bthr = 0.65, stars = 3000, weather = "Rain" }),
	["Crimson Dusk"] = makeEnv({ t = 18.3, br = 2.7, amb = rgb(165, 45, 55), out = rgb(255, 85, 65), fog = rgb(220, 60, 45), fogEnd = 1500, top = rgb(255, 145, 85), bot = rgb(255, 55, 65), exp = 0.2, dens = 0.36, off = 0.3, acol = rgb(255, 100, 75), adec = rgb(160, 25, 55), glare = 1, haze = 2, tint = rgb(255, 205, 195), sat = 0.65, con = 0.16, bloom = 1.3, rays = 0.45, stars = 0, weather = "Ash" }),
	["Emerald Jungle"] = makeEnv({ t = 11, br = 2.7, amb = rgb(60, 145, 85), out = rgb(110, 205, 130), fog = rgb(115, 205, 145), fogEnd = 750, top = rgb(205, 255, 180), bot = rgb(95, 200, 115), dens = 0.44, acol = rgb(130, 235, 165), adec = rgb(50, 150, 90), haze = 2.6, tint = rgb(215, 255, 220), sat = 0.6, con = 0.1, bloom = 0.9, rays = 0.4, stars = 0, weather = "Pollen" }),
	["Golden Hour"] = makeEnv({ t = 17.2, br = 3.3, amb = rgb(200, 125, 70), out = rgb(255, 190, 100), fog = rgb(255, 200, 125), fogEnd = 1900, top = rgb(255, 210, 120), bot = rgb(255, 160, 80), exp = 0.3, dens = 0.32, off = 0.25, acol = rgb(255, 200, 125), adec = rgb(255, 120, 55), glare = 1.2, haze = 1.7, tint = rgb(255, 228, 190), sat = 0.6, con = 0.14, bloom = 1.4, rays = 0.5, stars = 0, weather = "Pollen" }),
	["Volcanic"] = makeEnv({ t = 3, br = 1.9, amb = rgb(165, 45, 20), out = rgb(240, 80, 35), fog = rgb(100, 20, 8), fogEnd = 600, top = rgb(255, 115, 45), bot = rgb(255, 45, 15), dens = 0.52, acol = rgb(230, 75, 35), adec = rgb(120, 25, 12), haze = 3.2, tint = rgb(255, 195, 165), sat = 0.5, con = 0.3, bloom = 1.5, stars = 0, bodies = false, weather = "Embers" }),
	["Cosmic Void"] = makeEnv({ t = 0, br = 1.4, amb = rgb(55, 30, 125), out = rgb(100, 55, 215), fog = rgb(14, 6, 45), fogEnd = 1800, top = rgb(190, 100, 255), bot = rgb(55, 35, 225), dens = 0.3, acol = rgb(120, 65, 245), adec = rgb(35, 12, 115), haze = 1.2, tint = rgb(210, 190, 255), sat = 0.75, con = 0.16, bloom = 1.8, stars = 20000, moon = 30, weather = "Stardust" }),
	["Candy Sky"] = makeEnv({ t = 15, br = 3.3, amb = rgb(255, 180, 240), out = rgb(180, 225, 255), fog = rgb(255, 205, 245), fogEnd = 1700, top = rgb(255, 190, 245), bot = rgb(175, 220, 255), exp = 0.3, dens = 0.32, off = 0.2, acol = rgb(255, 195, 245), adec = rgb(160, 210, 255), glare = 0.6, haze = 1.8, tint = rgb(255, 235, 255), sat = 0.9, con = 0.05, bloom = 1.2, stars = 0, weather = "Stardust" }),
	["Ocean Sunrise"] = makeEnv({ t = 6.3, br = 2.9, amb = rgb(95, 155, 190), out = rgb(255, 185, 145), fog = rgb(255, 200, 170), fogEnd = 1700, top = rgb(255, 195, 135), bot = rgb(70, 195, 225), exp = 0.2, dens = 0.36, off = 0.2, acol = rgb(255, 190, 155), adec = rgb(60, 175, 210), glare = 1, haze = 1.8, tint = rgb(255, 232, 215), sat = 0.6, con = 0.1, bloom = 1.2, rays = 0.4, stars = 400 }),
	["Haunted Fog"] = makeEnv({ t = 2, br = 1, amb = rgb(55, 90, 80), out = rgb(80, 125, 110), fog = rgb(40, 68, 60), fogEnd = 320, top = rgb(115, 175, 150), bot = rgb(35, 65, 58), dens = 0.72, acol = rgb(65, 105, 92), adec = rgb(25, 48, 44), haze = 3.6, tint = rgb(195, 235, 215), sat = 0.1, con = 0.2, bloom = 0.6, blur = 2, stars = 3000, weather = "Fireflies" }),
	["Autumn Maple"] = makeEnv({ t = 16, br = 2.9, amb = rgb(185, 95, 55), out = rgb(250, 150, 85), fog = rgb(250, 180, 115), fogEnd = 1300, top = rgb(255, 180, 105), bot = rgb(240, 110, 55), exp = 0.2, dens = 0.36, acol = rgb(250, 160, 95), adec = rgb(210, 80, 35), glare = 0.8, haze = 2, tint = rgb(255, 220, 185), sat = 0.6, con = 0.12, bloom = 1.1, rays = 0.35, stars = 0, weather = "Leaves" }),
	["Monsoon"] = makeEnv({ t = 14.5, br = 1.3, amb = rgb(70, 88, 110), out = rgb(100, 122, 150), fog = rgb(72, 90, 110), fogEnd = 360, top = rgb(120, 155, 190), bot = rgb(85, 102, 130), dens = 0.58, acol = rgb(108, 128, 155), adec = rgb(58, 78, 105), haze = 3.4, tint = rgb(180, 205, 235), sat = 0, con = 0.22, bloom = 0.4, stars = 0, bodies = false, weather = "Heavy Rain" }),
	["Frozen Dawn"] = makeEnv({ t = 7, br = 2.9, amb = rgb(150, 175, 230), out = rgb(220, 205, 250), fog = rgb(225, 225, 255), fogEnd = 800, top = rgb(255, 200, 230), bot = rgb(185, 215, 255), exp = 0.3, dens = 0.42, off = 0.2, acol = rgb(235, 210, 250), adec = rgb(255, 150, 190), glare = 0.8, haze = 2.4, tint = rgb(235, 235, 255), sat = 0.45, con = 0.08, bloom = 1.2, rays = 0.35, stars = 900, weather = "Snow" }),

	["Lavender Dreams"] = makeEnv({ t = 17.5, br = 3, amb = rgb(185, 150, 255), out = rgb(205, 175, 255), fog = rgb(205, 180, 255), fogEnd = 1300, top = rgb(200, 150, 255), bot = rgb(150, 120, 255), exp = 0.3, dens = 0.42, off = 0.3, acol = rgb(205, 165, 255), adec = rgb(150, 90, 235), glare = 1, haze = 2.4, tint = rgb(235, 215, 255), sat = 0.7, con = 0.1, bloom = 1.5, rays = 0.4, stars = 1200, weather = "Stardust" }),
	["Tropical Sunset"] = makeEnv({ t = 18, br = 3.2, amb = rgb(255, 120, 110), out = rgb(255, 165, 90), fog = rgb(255, 150, 120), fogEnd = 1800, top = rgb(255, 205, 90), bot = rgb(255, 70, 130), exp = 0.3, dens = 0.34, off = 0.3, acol = rgb(255, 150, 105), adec = rgb(255, 55, 140), glare = 1.2, haze = 1.7, tint = rgb(255, 215, 190), sat = 0.85, con = 0.14, bloom = 1.5, rays = 0.5, stars = 0, weather = "Pollen" }),
	["Rose Gold"] = makeEnv({ t = 17, br = 3.1, amb = rgb(230, 150, 145), out = rgb(255, 185, 160), fog = rgb(255, 190, 170), fogEnd = 1500, top = rgb(255, 195, 165), bot = rgb(235, 130, 150), exp = 0.3, dens = 0.38, off = 0.28, acol = rgb(255, 185, 165), adec = rgb(225, 105, 130), glare = 1, haze = 2, tint = rgb(255, 225, 210), sat = 0.6, con = 0.12, bloom = 1.3, rays = 0.4, stars = 0, weather = "Petals" }),
	["Arctic Aurora"] = makeEnv({ t = 23, br = 2, amb = rgb(40, 150, 175), out = rgb(80, 215, 215), fog = rgb(10, 60, 95), fogEnd = 1500, top = rgb(100, 255, 215), bot = rgb(140, 90, 255), exp = 0.15, dens = 0.34, acol = rgb(85, 255, 215), adec = rgb(150, 85, 255), haze = 1.6, tint = rgb(195, 255, 245), sat = 0.8, con = 0.15, bloom = 1.6, stars = 14000, weather = "Snow" }),
	["Toxic Swamp"] = makeEnv({ t = 20, br = 1.8, amb = rgb(75, 165, 55), out = rgb(120, 225, 70), fog = rgb(55, 110, 30), fogEnd = 500, top = rgb(175, 255, 80), bot = rgb(60, 150, 45), dens = 0.6, acol = rgb(120, 230, 65), adec = rgb(55, 120, 30), haze = 3.4, tint = rgb(215, 255, 190), sat = 0.7, con = 0.2, bloom = 1.3, stars = 2500, weather = "Fireflies" }),
	["Royal Violet"] = makeEnv({ t = 19, br = 2.4, amb = rgb(110, 55, 185), out = rgb(155, 90, 240), fog = rgb(75, 30, 140), fogEnd = 1100, top = rgb(205, 125, 255), bot = rgb(95, 55, 230), exp = 0.2, dens = 0.4, acol = rgb(165, 95, 250), adec = rgb(80, 30, 175), glare = 0.8, haze = 2.2, tint = rgb(230, 205, 255), sat = 0.8, con = 0.18, bloom = 1.6, stars = 5000, weather = "Stardust" }),
}

-- Vibrance pass: every preset (except the untouched game default and the muted weather ones) gets richer color.
for name, env in pairs(ENVIRONMENTS) do
	if name ~= "Default" and name ~= "Haunted Fog" and name ~= "Monsoon" and name ~= "Storm" then
		env.sat = math.min(env.sat + 0.12, 1.2)
		env.bloom = env.bloom + 0.15
	end
end

--------------------------------------------------------------------------------
-- World: weather particles (spawned above the camera, falling onto the player)
--------------------------------------------------------------------------------

local SMOKE_TEXTURE = "rbxasset://textures/particles/smoke_main.dds"
local SPARKLE_TEXTURE = "rbxasset://textures/particles/sparkles_main.dds"

local function v3(x, y, z)
	return Vector3.new(x, y, z)
end

local function v2(x, y)
	return Vector2.new(x, y)
end

local PARALLEL = Enum.ParticleOrientation.VelocityParallel

local WEATHERS = {
	Snow = { layers = {
		{ tex = "flake", rate = 170, life = { 10, 13 }, speed = { 3, 6 }, size = 0.32, colors = { rgb(255, 255, 255), rgb(215, 230, 255) }, accel = v3(0, -2.5, 0), drag = 0.4, rot = { -40, 40 }, spread = v2(14, 14), emit = 0.35, infl = 0.3, trans = 0.12, wind = 1.2 },
		{ tex = "flake", rate = 110, life = { 9, 12 }, speed = { 4, 7 }, size = 0.6, colors = { rgb(255, 255, 255), rgb(225, 238, 255) }, accel = v3(0, -3.5, 0), drag = 0.35, rot = { -60, 60 }, spread = v2(20, 20), emit = 0.3, infl = 0.4, trans = 0.2, wind = 1.4 },
		{ tex = "glow", rate = 45, life = { 7, 9 }, speed = { 8, 12 }, size = 1.5, colors = { rgb(255, 255, 255), rgb(235, 245, 255) }, accel = v3(0, -5, 0), drag = 0.2, rot = { 0, 0 }, spread = v2(10, 10), emit = 0.5, infl = 0.3, trans = 0.62, wind = 1.8 },
		{ tex = "glow", rate = 260, life = { 7, 10 }, speed = { 5, 9 }, size = 0.14, colors = { rgb(255, 255, 255), rgb(255, 255, 255) }, accel = v3(0, -3, 0), drag = 0.3, rot = { 0, 0 }, spread = v2(25, 25), emit = 0.4, infl = 0.5, trans = 0.05, wind = 1.6 },
	} },
	Blizzard = { layers = {
		{ tex = "flake", rate = 420, life = { 4, 6 }, speed = { 20, 30 }, size = 0.4, colors = { rgb(255, 255, 255), rgb(220, 232, 255) }, accel = v3(0, -10, 0), drag = 0.1, rot = { -80, 80 }, spread = v2(8, 8), emit = 0.3, infl = 0.4, trans = 0.15, wind = 5 },
		{ tex = "glow", rate = 500, life = { 3.5, 5 }, speed = { 24, 34 }, size = 0.17, colors = { rgb(255, 255, 255), rgb(255, 255, 255) }, accel = v3(0, -12, 0), drag = 0.1, rot = { 0, 0 }, spread = v2(8, 8), emit = 0.2, infl = 0.5, trans = 0.08, wind = 6 },
		{ tex = "smoke", rate = 18, life = { 6, 8 }, speed = { 20, 28 }, size = 22, colors = { rgb(240, 246, 255), rgb(225, 235, 250) }, accel = v3(0, -8, 0), drag = 0.2, rot = { -8, 8 }, spread = v2(6, 6), emit = 0.1, infl = 0.6, trans = 0.93, wind = 5 },
	} },
	-- Petals: a wide canopy plus dense layers right around the player so they fall where you stand.
	Petals = { layers = {
		{ tex = "petal", rate = 110, life = { 11, 14 }, speed = { 1, 3 }, size = 1.0, colors = { rgb(255, 95, 160), rgb(255, 150, 195) }, accel = v3(0, -3.2, 0), drag = 0.5, rot = { -160, 160 }, spread = v2(10, 10), emit = 0.2, infl = 0.15, trans = 0.05, wind = 1.3 },
		{ tex = "petal", rate = 90, life = { 11, 14 }, speed = { 1, 3 }, size = 0.85, colors = { rgb(255, 205, 225), rgb(255, 175, 205) }, accel = v3(0, -2.8, 0), drag = 0.5, rot = { -190, 190 }, spread = v2(10, 10), emit = 0.25, infl = 0.15, trans = 0.05, wind = 1.5 },
		{ tex = "petal", rate = 60, life = { 10, 13 }, speed = { 1, 3 }, size = 0.7, colors = { rgb(235, 60, 130), rgb(255, 110, 165) }, accel = v3(0, -3.6, 0), drag = 0.5, rot = { -220, 220 }, spread = v2(10, 10), emit = 0.1, infl = 0.25, trans = 0.05, wind = 1.7 },
		{ tex = "petal", rate = 18, life = { 8, 10 }, speed = { 3, 6 }, size = 2.4, colors = { rgb(255, 130, 180), rgb(255, 190, 215) }, accel = v3(0, -5, 0), drag = 0.4, rot = { -120, 120 }, spread = v2(12, 12), emit = 0.2, infl = 0.2, trans = 0.5, wind = 1.6 },
		{ tex = "glow", rate = 70, life = { 9, 12 }, speed = { 1, 2 }, size = 0.55, colors = { rgb(255, 170, 210), rgb(255, 235, 245) }, accel = v3(0, -1.5, 0), drag = 0.4, rot = { -30, 30 }, spread = v2(20, 20), emit = 1, infl = 0, twinkle = true, wind = 0.8 },
		{ near = true, tex = "petal", rate = 70, life = { 5, 8 }, speed = { 0.5, 2 }, size = 0.9, colors = { rgb(255, 100, 165), rgb(255, 160, 200) }, accel = v3(0, -2.4, 0), drag = 0.7, rot = { -200, 200 }, spread = v2(40, 40), emit = 0.25, infl = 0.1, trans = 0.03, wind = 1.4 },
		{ near = true, tex = "petal", rate = 55, life = { 5, 8 }, speed = { 0.5, 2 }, size = 0.7, colors = { rgb(255, 215, 232), rgb(255, 185, 212) }, accel = v3(0, -2.1, 0), drag = 0.7, rot = { -240, 240 }, spread = v2(40, 40), emit = 0.3, infl = 0.1, trans = 0.03, wind = 1.6 },
		{ near = true, tex = "petal", rate = 30, life = { 4, 7 }, speed = { 1, 3 }, size = 1.6, colors = { rgb(255, 120, 175), rgb(255, 175, 210) }, accel = v3(0, -3, 0), drag = 0.6, rot = { -140, 140 }, spread = v2(30, 30), emit = 0.2, infl = 0.15, trans = 0.35, wind = 1.5 },
		{ near = true, tex = "glow", rate = 40, life = { 4, 7 }, speed = { 0.3, 1.2 }, size = 0.45, colors = { rgb(255, 200, 225), rgb(255, 245, 250) }, accel = v3(0, -0.8, 0), drag = 0.5, rot = { 0, 0 }, spread = v2(60, 60), emit = 1, infl = 0, twinkle = true, wind = 0.7 },
	} },
	["Blossom Rain"] = { layers = {
		{ tex = "petal", rate = 240, life = { 5, 7 }, speed = { 10, 16 }, size = 0.65, colors = { rgb(255, 150, 190), rgb(255, 110, 165) }, accel = v3(0, -9, 0), drag = 0.3, rot = { -220, 220 }, spread = v2(12, 12), emit = 0.2, infl = 0.3, trans = 0.08, wind = 2.2 },
		{ tex = "petal", rate = 170, life = { 5, 7 }, speed = { 10, 16 }, size = 0.55, colors = { rgb(255, 235, 242), rgb(255, 205, 225) }, accel = v3(0, -9, 0), drag = 0.3, rot = { -240, 240 }, spread = v2(12, 12), emit = 0.25, infl = 0.3, trans = 0.08, wind = 2.4 },
		{ tex = "streak", rate = 260, life = { 0.55, 0.7 }, speed = { 70, 90 }, size = 1.4, colors = { rgb(255, 190, 220), rgb(255, 160, 200) }, accel = v3(0, -50, 0), drag = 0, rot = { 0, 0 }, spread = v2(1, 1), emit = 0.4, infl = 0.2, orient = PARALLEL, trans = 0.35, wind = 0.4 },
		{ near = true, tex = "petal", rate = 80, life = { 3, 5 }, speed = { 4, 8 }, size = 0.8, colors = { rgb(255, 130, 180), rgb(255, 200, 220) }, accel = v3(0, -7, 0), drag = 0.4, rot = { -240, 240 }, spread = v2(25, 25), emit = 0.3, infl = 0.2, trans = 0.05, wind = 1.8 },
	} },
	Rain = { layers = {
		{ tex = "streak", rate = 900, life = { 0.5, 0.62 }, speed = { 95, 115 }, size = 1.8, colors = { rgb(200, 220, 255), rgb(170, 195, 235) }, accel = v3(0, -65, 0), drag = 0, rot = { 0, 0 }, spread = v2(1, 1), emit = 0.2, infl = 0.4, orient = PARALLEL, trans = 0.3, wind = 0.35 },
		{ tex = "streak", rate = 500, life = { 0.45, 0.58 }, speed = { 110, 135 }, size = 1.2, colors = { rgb(225, 235, 255), rgb(200, 215, 245) }, accel = v3(0, -75, 0), drag = 0, rot = { 0, 0 }, spread = v2(1, 1), emit = 0.3, infl = 0.3, orient = PARALLEL, trans = 0.4, wind = 0.35 },
		{ tex = "streak", rate = 60, life = { 0.4, 0.5 }, speed = { 120, 140 }, size = 3.2, colors = { rgb(215, 230, 255), rgb(190, 210, 245) }, accel = v3(0, -80, 0), drag = 0, rot = { 0, 0 }, spread = v2(1, 1), emit = 0.2, infl = 0.3, orient = PARALLEL, trans = 0.65, wind = 0.35 },
		{ tex = "smoke", rate = 14, life = { 5, 7 }, speed = { 1, 3 }, size = 26, colors = { rgb(150, 165, 190), rgb(120, 135, 160) }, accel = v3(0, 0, 0), drag = 0.5, rot = { -5, 5 }, spread = v2(30, 30), emit = 0, infl = 0.7, trans = 0.94, wind = 1.5 },
	} },
	["Heavy Rain"] = { layers = {
		{ tex = "streak", rate = 1600, life = { 0.45, 0.58 }, speed = { 130, 160 }, size = 2.2, colors = { rgb(190, 210, 245), rgb(160, 185, 230) }, accel = v3(0, -90, 0), drag = 0, rot = { 0, 0 }, spread = v2(2, 2), emit = 0.15, infl = 0.4, orient = PARALLEL, trans = 0.25, wind = 1.1 },
		{ tex = "streak", rate = 900, life = { 0.4, 0.52 }, speed = { 140, 170 }, size = 1.5, colors = { rgb(220, 230, 255), rgb(190, 205, 240) }, accel = v3(0, -100, 0), drag = 0, rot = { 0, 0 }, spread = v2(2, 2), emit = 0.25, infl = 0.3, orient = PARALLEL, trans = 0.35, wind = 1.2 },
		{ tex = "streak", rate = 110, life = { 0.35, 0.45 }, speed = { 150, 180 }, size = 3.8, colors = { rgb(210, 225, 255), rgb(185, 205, 245) }, accel = v3(0, -110, 0), drag = 0, rot = { 0, 0 }, spread = v2(2, 2), emit = 0.2, infl = 0.3, orient = PARALLEL, trans = 0.6, wind = 1.2 },
		{ tex = "smoke", rate = 22, life = { 4, 6 }, speed = { 8, 14 }, size = 30, colors = { rgb(120, 135, 160), rgb(95, 110, 135) }, accel = v3(0, -4, 0), drag = 0.5, rot = { -6, 6 }, spread = v2(30, 30), emit = 0, infl = 0.7, trans = 0.9, wind = 3 },
	} },
	Leaves = { layers = {
		{ tex = "leaf", rate = 40, life = { 11, 15 }, speed = { 2, 5 }, size = 0.95, colors = { rgb(210, 115, 35), rgb(155, 175, 50) }, accel = v3(0, -2, 0), drag = 0.8, rot = { -180, 180 }, spread = v2(30, 30), emit = 0, infl = 0.5, trans = 0.05, wind = 2 },
		{ tex = "leaf", rate = 30, life = { 11, 15 }, speed = { 2, 5 }, size = 0.8, colors = { rgb(180, 70, 25), rgb(235, 175, 45) }, accel = v3(0, -1.8, 0), drag = 0.8, rot = { -200, 200 }, spread = v2(30, 30), emit = 0, infl = 0.5, trans = 0.05, wind = 2.2 },
		{ tex = "leaf", rate = 10, life = { 8, 11 }, speed = { 3, 6 }, size = 1.8, colors = { rgb(200, 100, 30), rgb(170, 150, 40) }, accel = v3(0, -3, 0), drag = 0.6, rot = { -120, 120 }, spread = v2(20, 20), emit = 0, infl = 0.5, trans = 0.45, wind = 2.4 },
		{ near = true, tex = "leaf", rate = 22, life = { 5, 8 }, speed = { 1, 3 }, size = 0.9, colors = { rgb(215, 110, 30), rgb(240, 180, 50) }, accel = v3(0, -2.2, 0), drag = 0.7, rot = { -200, 200 }, spread = v2(40, 40), emit = 0, infl = 0.3, trans = 0.03, wind = 1.8 },
	} },
	Ash = { layers = {
		{ tex = "ash", rate = 120, life = { 9, 13 }, speed = { 2, 5 }, size = 0.45, colors = { rgb(165, 165, 170), rgb(95, 95, 100) }, accel = v3(0, -1.3, 0), drag = 0.6, rot = { -50, 50 }, spread = v2(30, 30), emit = 0, infl = 0.6, trans = 0.15, wind = 1.4 },
		{ tex = "glow", rate = 30, life = { 7, 10 }, speed = { 3, 6 }, size = 0.2, colors = { rgb(255, 120, 40), rgb(255, 200, 90) }, accel = v3(0, -1, 0), drag = 0.4, rot = { 0, 0 }, spread = v2(30, 30), emit = 1, infl = 0, twinkle = true, wind = 1.2 },
		{ tex = "smoke", rate = 8, life = { 7, 9 }, speed = { 2, 4 }, size = 30, colors = { rgb(70, 70, 76), rgb(50, 50, 56) }, accel = v3(0, -1, 0), drag = 0.5, rot = { -4, 4 }, spread = v2(30, 30), emit = 0, infl = 0.8, trans = 0.93, wind = 1.5 },
	} },
	Embers = { fixedHeight = -6, layers = {
		{ tex = "glow", rate = 140, life = { 4, 8 }, speed = { 5, 12 }, size = 0.4, colors = { rgb(255, 175, 60), rgb(210, 45, 20) }, accel = v3(0, 3, 0), drag = 0.3, rot = { -90, 90 }, spread = v2(30, 30), emit = 1, infl = 0, dir = Enum.NormalId.Top, trans = 0.08, wind = 0.8 },
		{ tex = "glow", rate = 30, life = { 5, 8 }, speed = { 4, 9 }, size = 1.2, colors = { rgb(255, 120, 40), rgb(200, 50, 20) }, accel = v3(0, 2.5, 0), drag = 0.3, rot = { 0, 0 }, spread = v2(30, 30), emit = 1, infl = 0, dir = Enum.NormalId.Top, trans = 0.65, wind = 0.9 },
	} },
	Fireflies = { fixedHeight = 3, layers = {
		{ tex = "glow", rate = 30, life = { 6, 10 }, speed = { 0.5, 2 }, size = 0.55, colors = { rgb(215, 255, 120), rgb(255, 240, 130) }, accel = v3(0, 0, 0), drag = 0.2, rot = { 0, 0 }, spread = v2(180, 180), emit = 1, infl = 0, dir = Enum.NormalId.Top, twinkle = true, wind = 0.2 },
		{ tex = "glow", rate = 12, life = { 7, 11 }, speed = { 0.3, 1.2 }, size = 1.5, colors = { rgb(190, 255, 110), rgb(255, 245, 150) }, accel = v3(0, 0, 0), drag = 0.2, rot = { 0, 0 }, spread = v2(180, 180), emit = 1, infl = 0, dir = Enum.NormalId.Top, twinkle = true, wind = 0.2 },
	} },
	Stardust = { layers = {
		{ tex = "glow", rate = 120, life = { 8, 12 }, speed = { 1, 3 }, size = 0.55, colors = { rgb(200, 170, 255), rgb(150, 220, 255) }, accel = v3(0, -1, 0), drag = 0.3, rot = { -40, 40 }, spread = v2(40, 40), emit = 1, infl = 0, twinkle = true, wind = 0.6 },
		{ tex = "glow", rate = 30, life = { 9, 13 }, speed = { 1, 2 }, size = 1.4, colors = { rgb(255, 190, 240), rgb(190, 200, 255) }, accel = v3(0, -0.8, 0), drag = 0.3, rot = { 0, 0 }, spread = v2(40, 40), emit = 1, infl = 0, twinkle = true, wind = 0.6 },
	} },
	Pollen = { layers = {
		{ tex = "glow", rate = 70, life = { 9, 13 }, speed = { 1, 3 }, size = 0.4, colors = { rgb(255, 245, 160), rgb(255, 215, 110) }, accel = v3(0, -0.6, 0), drag = 0.3, rot = { 0, 0 }, spread = v2(40, 40), emit = 1, infl = 0, twinkle = true, wind = 1.1 },
		{ tex = "glow", rate = 18, life = { 9, 13 }, speed = { 1, 2 }, size = 1.1, colors = { rgb(255, 235, 150), rgb(255, 255, 210) }, accel = v3(0, -0.5, 0), drag = 0.3, rot = { 0, 0 }, spread = v2(40, 40), emit = 1, infl = 0, twinkle = true, wind = 1.2 },
	} },
}

local function buildSizeSequence(base)
	return NumberSequence.new({ NumberSequenceKeypoint.new(0, base, base * 0.4), NumberSequenceKeypoint.new(1, base, base * 0.4) })
end

local function buildTransparencySequence(layer)
	if layer.twinkle then
		return NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.2, 0.2), NumberSequenceKeypoint.new(0.45, 0.8),
			NumberSequenceKeypoint.new(0.7, 0.1), NumberSequenceKeypoint.new(1, 1),
		})
	end

	local trans = layer.trans or 0.2
	return NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.1, trans), NumberSequenceKeypoint.new(0.88, trans), NumberSequenceKeypoint.new(1, 1) })
end

---Scale a layer's gravity by the fall speed setting.
local function fallAcceleration(layer)
	return v3(layer.accel.X, layer.accel.Y * Config.world.fallSpeed / 100, layer.accel.Z)
end

---Pick the embedded texture, falling back to Roblox's built-in particles.
local function pickTexture(name)
	local key = name == "ash" and "glow" or name
	local asset = textureAssets[key]

	if asset then
		return asset
	end

	return (name == "glow" or name == "flake") and SPARKLE_TEXTURE or SMOKE_TEXTURE
end

function Weather.createEmitter(layer, part)
	local world = Config.world
	local fall = world.fallSpeed / 100

	return new("ParticleEmitter", {
		Texture = pickTexture(layer.tex),
		Rate = 0,
		Lifetime = NumberRange.new(layer.life[1], layer.life[2]),
		Speed = NumberRange.new(layer.speed[1] * fall, layer.speed[2] * fall),
		SpreadAngle = layer.spread,
		EmissionDirection = layer.dir or Enum.NormalId.Bottom,
		Acceleration = fallAcceleration(layer),
		Drag = layer.drag or 0,
		Color = ColorSequence.new(layer.colors[1], layer.colors[2]),
		Transparency = buildTransparencySequence(layer),
		Size = buildSizeSequence(layer.size * world.particleSize / 100),
		LightEmission = layer.emit or 0,
		LightInfluence = layer.infl or 0.5,
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(layer.rot[1], layer.rot[2]),
		Orientation = layer.orient or Enum.ParticleOrientation.FacingCamera,
		LockedToPart = false,
	}, part)
end

---Fade out the active weather and let its remaining particles finish.
function Weather.retire()
	for _, entry in ipairs(Weather.entries) do
		tweenService:Create(entry.emitter, TweenInfo.new(1.5, Enum.EasingStyle.Sine), { Rate = 0 }):Play()
	end

	for _, oldPart in ipairs({ Weather.part, Weather.near }) do
		if oldPart then
			task.delay(16, function()
				oldPart:Destroy()
			end)
		end
	end

	Weather.part = nil
	Weather.near = nil
	Weather.entries = {}
	Weather.preset = nil
end

local function makeWeatherPart(name, size, parent)
	return new("Part", {
		Name = name,
		Anchored = true,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		Transparency = 1,
		Size = size,
	}, parent)
end

---Switch to a weather type with a smooth fade in and out.
function Weather.set(name)
	Weather.retire()

	local preset = WEATHERS[name]
	if not preset then
		return
	end

	local world = Config.world
	local camera = workspace.CurrentCamera

	Weather.part = makeWeatherPart("VexoraWeather", Vector3.new(world.radius * 2, 1, world.radius * 2), camera)
	Weather.preset = preset

	-- A smaller, denser emitter that follows the character so particles fall where you stand.
	if world.nearPetals then
		for _, layer in ipairs(preset.layers) do
			if layer.near then
				Weather.near = makeWeatherPart("VexoraWeatherNear", Vector3.new(44, 1, 44), camera)
				break
			end
		end
	end

	for _, layer in ipairs(preset.layers) do
		local target = layer.near and Weather.near or Weather.part

		if target then
			local emitter = Weather.createEmitter(layer, target)
			tweenService:Create(emitter, TweenInfo.new(2, Enum.EasingStyle.Sine), { Rate = layer.rate * world.intensity / 100 }):Play()
			table.insert(Weather.entries, { emitter = emitter, layer = layer })
		end
	end

	Weather.update()
end

function Weather.applyTuning()
	local world = Config.world
	local fall = world.fallSpeed / 100

	if Weather.part then
		Weather.part.Size = Vector3.new(world.radius * 2, 1, world.radius * 2)
	end

	for _, entry in ipairs(Weather.entries) do
		local layer = entry.layer
		tweenService:Create(entry.emitter, TweenInfo.new(0.4), { Rate = layer.rate * world.intensity / 100 }):Play()
		entry.emitter.Size = buildSizeSequence(layer.size * world.particleSize / 100)
		entry.emitter.Speed = NumberRange.new(layer.speed[1] * fall, layer.speed[2] * fall)
	end
end

---Keep the weather above the camera and the player, and apply gusting wind.
function Weather.update()
	if not Weather.part then
		return
	end

	local camera = workspace.CurrentCamera

	if Weather.part.Parent ~= camera then
		Weather.part.Parent = camera
	end

	local world = Config.world
	Weather.part.CFrame = CFrame.new(camera.CFrame.Position + Vector3.new(0, Weather.preset.fixedHeight or world.height, 0))

	if Weather.near then
		if Weather.near.Parent ~= camera then
			Weather.near.Parent = camera
		end

		local character = localPlayer.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local anchor = root and root.Position or camera.CFrame.Position
		Weather.near.CFrame = CFrame.new(anchor + Vector3.new(0, 16, 0))
	end

	local now = os.clock()
	local gust = 0.8 + 0.2 * math.sin(now * 0.5) + 0.1 * math.sin(now * 1.3)
	local rad = math.rad(world.windDirection)
	local wind = Vector3.new(math.cos(rad), 0, math.sin(rad)) * world.windStrength * gust

	for _, entry in ipairs(Weather.entries) do
		entry.emitter.Acceleration = fallAcceleration(entry.layer) + wind * (entry.layer.wind or 1)
	end
end

--------------------------------------------------------------------------------
-- World: applying environments
--------------------------------------------------------------------------------

---Build the adjustable foggy environment from the fog sliders.
function World.buildFoggy()
	local world = Config.world
	local density = world.fogDensity

	return makeEnv({
		t = 12, br = 2.4, amb = rgb(200, 205, 212), out = rgb(215, 220, 226), fog = rgb(236, 239, 243), fogEnd = 520 - density * 460, top = rgb(235, 240, 245), bot = rgb(245, 247, 250), exp = 0.2,
		dens = density, acol = rgb(238, 241, 245), adec = rgb(228, 231, 236), haze = 2 + density * 6,
		tint = rgb(242, 245, 248), sat = -0.2, con = -0.05, bloom = 0.4, blur = world.fogBlur, stars = 0, bodies = false,
	})
end

function World.getPreset(name)
	if name == "Foggy" then
		return World.buildFoggy()
	end

	return ENVIRONMENTS[name]
end

---Whether another toggle currently owns this live value.
local function isLocked(key)
	local world = Config.world

	if key == "t" then
		return world.timeLock
	elseif key == "br" or key == "amb" or key == "out" then
		return world.fullbright
	elseif key == "fogStart" or key == "fogEnd" or key == "dens" then
		return world.noFog
	elseif key == "tint" then
		return world.rainbowTint
	end

	return false
end

local function cancelTweens()
	for _, tween in ipairs(World.tweens) do
		tween:Cancel()
	end

	table.clear(World.tweens)
end

---Smoothly move every bound instance to the live values.
function World.tweenToLive(duration)
	cancelTweens()

	local goals = {}

	for _, bind in ipairs(BINDINGS) do
		local key, instance, property = bind[1], bind[2], bind[3]
		local value = Config.world.live[key]

		if value ~= nil and not isLocked(key) then
			goals[instance] = goals[instance] or {}
			goals[instance][property] = value
		end
	end

	local info = TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

	for instance, goal in pairs(goals) do
		local tween = tweenService:Create(instance, info, goal)
		tween:Play()
		table.insert(World.tweens, tween)
	end
end

---Write the live values instantly (used by sliders and color pickers).
function World.pushLive()
	cancelTweens()

	for _, bind in ipairs(BINDINGS) do
		local key, instance, property = bind[1], bind[2], bind[3]
		local value = Config.world.live[key]

		if value ~= nil and not isLocked(key) then
			pcall(function()
				instance[property] = value
			end)
		end
	end
end

---Apply the sky textures and celestial settings.
function World.applySky()
	local world = Config.world
	local faces

	if world.skyId ~= "" then
		faces = {}

		for _, face in ipairs(SKY_FACES) do
			faces[face] = "rbxassetid://" .. world.skyId
		end
	elseif world.skyMode == "Game Default" or (world.skyMode == "Match Environment" and world.environment == "Default") then
		faces = originalSky.faces
	elseif world.skyMode == "Roblox Classic" then
		faces = CLASSIC_SKY
	else
		faces = {}
	end

	for _, face in ipairs(SKY_FACES) do
		pcall(function()
			sky[face] = faces[face] or ""
		end)
	end

	pcall(function()
		sky.CelestialBodiesShown = world.live.bodies ~= false
		sky.SunAngularSize = world.sunSize
		sky.MoonAngularSize = world.moonSize
	end)
end

---Switch to an environment: copy it into the live values, then fade to it.
function World.select(name, duration)
	local world = Config.world
	local preset = World.getPreset(name)
	if not preset then
		return
	end

	world.environment = name

	for key, value in pairs(preset) do
		world.live[key] = value
	end

	world.sunSize = originalSky.SunAngularSize
	world.moonSize = preset.moon or originalSky.MoonAngularSize

	if world.autoWeather then
		world.weather = preset.weather
		Weather.set(world.weather)
	end

	Vexora.refreshUi()
	World.tweenToLive(duration or world.transition)
	World.applySky()
end

function World.flashLightning()
	for _ = 1, math.random(1, 3) do
		tweenService:Create(lighting, TweenInfo.new(0.06), { ExposureCompensation = 2.4 }):Play()
		task.wait(0.08)
		tweenService:Create(lighting, TweenInfo.new(0.45, Enum.EasingStyle.Quad), { ExposureCompensation = Config.world.live.exp or 0 }):Play()
		task.wait(0.22)
	end
end

--------------------------------------------------------------------------------
-- World: effects (grading presets, depth of field, vignette, filter)
--------------------------------------------------------------------------------

local EFFECT_DATA = {
	Cinematic = { sat = 0.12, con = 0.28, gb = -0.02, tint = rgb(255, 238, 220), bloom = 0.9, bsize = 30, bthr = 0.9, rays = 0.3, blur = 0 },
	Vivid = { sat = 0.9, con = 0.2, gb = 0.02, tint = rgb(255, 250, 245), bloom = 1.1, bsize = 32, bthr = 0.85, rays = 0.3, blur = 0 },
	Dreamy = { sat = 0.45, con = -0.05, gb = 0.07, tint = rgb(255, 225, 240), bloom = 2.4, bsize = 52, bthr = 0.55, rays = 0.5, blur = 1.5 },
	Noir = { sat = -1, con = 0.4, gb = -0.03, tint = rgb(255, 255, 255), bloom = 0.5, bsize = 24, bthr = 1, rays = 0.1, blur = 0 },
	Retro = { sat = 0.55, con = 0.22, gb = 0.02, tint = rgb(255, 218, 175), bloom = 1.3, bsize = 36, bthr = 0.8, rays = 0.2, blur = 0.6 },
	["Neon Glow"] = { sat = 1.1, con = 0.25, gb = -0.02, tint = rgb(235, 215, 255), bloom = 2.6, bsize = 56, bthr = 0.5, rays = 0.35, blur = 0 },
	["Ultra Quality"] = { sat = 0.5, con = 0.2, gb = 0.02, tint = rgb(255, 245, 240), bloom = 1.2, bsize = 34, bthr = 0.8, rays = 0.4, blur = 0, dof = true, softShadows = true },
}

function Effects.apply(name)
	local world = Config.world
	local data = EFFECT_DATA[name]
	if not data then
		return
	end

	for key, value in pairs(data) do
		if key == "dof" then
			world.dof = value
		elseif key == "softShadows" then
			world.softShadows = value
		else
			world.live[key] = value
		end
	end

	Vexora.refreshUi()
	World.tweenToLive(0.8)
end

---Cached gradient values so the vignette only rebuilds on change.
local vignetteCache = ""

function Effects.updateOverlays()
	local world = Config.world

	filterFrame.Visible = world.filter
	filterFrame.BackgroundColor3 = world.filterColor
	filterFrame.BackgroundTransparency = 1 - math.clamp(world.filterOpacity, 0, 1) * 0.35

	local key = string.format("%s|%.2f|%.2f", world.vignetteColor:ToHex(), world.vignetteOpacity, world.vignetteSize)

	for index, entry in ipairs(vignetteFrames) do
		entry.frame.Visible = world.vignette

		if world.vignette and key ~= vignetteCache then
			local size = world.vignetteSize
			entry.frame.BackgroundColor3 = world.vignetteColor
			entry.fade.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1 - world.vignetteOpacity), NumberSequenceKeypoint.new(1, 1) })

			if index <= 2 then
				entry.frame.Size = UDim2.fromScale(1, size)
			else
				entry.frame.Size = UDim2.fromScale(size * 0.6, 1)
			end
		end
	end

	if world.vignette then
		vignetteCache = key
	end
end

---Enforce toggle based world overrides each frame.
function World.updateOverrides()
	local world = Config.world

	if world.timeLock then
		lighting.ClockTime = world.timeOfDay
	end

	if world.fullbright then
		lighting.Brightness = 3
		lighting.Ambient = rgb(200, 200, 200)
		lighting.OutdoorAmbient = rgb(200, 200, 200)
	end

	if world.noFog then
		lighting.FogStart = 9e9
		lighting.FogEnd = 9e9
		atmosphere.Density = 0
	end

	if world.noShadows then
		lighting.GlobalShadows = false
	end

	if world.softShadows then
		lighting.ShadowSoftness = world.shadowSoftness
	end

	if world.rainbowTint then
		gradeEffect.TintColor = Color3.fromHSV((os.clock() * world.rainbowTintSpeed) % 1, 0.35, 1)
	end

	dofEffect.Enabled = world.dof
	dofEffect.FocusDistance = world.dofFocus
	dofEffect.InFocusRadius = world.dofRadius
	dofEffect.FarIntensity = world.dofFar
	dofEffect.NearIntensity = world.dofNear

	Effects.updateOverlays()
end

--------------------------------------------------------------------------------
-- Misc: No Lag mode, movement, crosshair
--------------------------------------------------------------------------------

local Misc = { frames = 0, lastFps = os.clock(), fps = 60, spin = 0, cross = nil, orig = {}, clickAt = 0 }
local NoLag = { cache = setmetatable({}, { __mode = "k" }), connection = nil, token = 0, saved = {} }

local DISABLE_CLASSES = { "ParticleEmitter", "Trail", "Beam", "Fire", "Smoke", "Sparkles", "Explosion" }

local function isClass(instance, classes)
	for _, className in ipairs(classes) do
		if instance:IsA(className) then
			return true
		end
	end

	return false
end

---Strip textures, materials and effects from one instance (reversible).
function NoLag.process(instance)
	if instance.Name:sub(1, 6) == "Vexora" or (instance.Parent and instance.Parent.Name:sub(1, 13) == "VexoraWeather") then
		return
	end

	local record

	if instance:IsA("Terrain") then
		return
	elseif instance:IsA("BasePart") then
		local model = instance:FindFirstAncestorOfClass("Model")
		if model and model:FindFirstChildOfClass("Humanoid") then
			return
		end

		record = { Material = instance.Material, Reflectance = instance.Reflectance, CastShadow = instance.CastShadow }
		instance.Material = Enum.Material.SmoothPlastic
		instance.Reflectance = 0
		instance.CastShadow = false

		if instance:IsA("MeshPart") then
			record.TextureID = instance.TextureID
			pcall(function()
				instance.TextureID = ""
			end)
		end
	elseif instance:IsA("Decal") or instance:IsA("Texture") then
		record = { Transparency = instance.Transparency }
		instance.Transparency = 1
	elseif isClass(instance, DISABLE_CLASSES) then
		record = { Enabled = instance.Enabled }
		instance.Enabled = false
	end

	if record then
		NoLag.cache[instance] = record
	end
end

function NoLag.set(enabled)
	NoLag.token += 1
	local token = NoLag.token

	if NoLag.connection then
		NoLag.connection:Disconnect()
		NoLag.connection = nil
	end

	if enabled then
		local terrain = workspace:FindFirstChildOfClass("Terrain")

		pcall(function()
			NoLag.saved.quality = settings().Rendering.QualityLevel
			settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
		end)

		if terrain then
			NoLag.saved.terrain = { Decoration = terrain.Decoration, WaterWaveSize = terrain.WaterWaveSize, WaterWaveSpeed = terrain.WaterWaveSpeed, WaterReflectance = terrain.WaterReflectance }
			pcall(function()
				terrain.Decoration = false
				terrain.WaterWaveSize = 0
				terrain.WaterWaveSpeed = 0
				terrain.WaterReflectance = 0
			end)
		end

		Config.world.noShadows = true
		Vexora.refreshUi()

		NoLag.connection = workspace.DescendantAdded:Connect(function(instance)
			pcall(NoLag.process, instance)
		end)

		task.spawn(function()
			local descendants = workspace:GetDescendants()

			for index, instance in ipairs(descendants) do
				if token ~= NoLag.token then
					return
				end

				pcall(NoLag.process, instance)

				if index % 400 == 0 then
					task.wait()
				end
			end
		end)

		return
	end

	for instance, record in pairs(NoLag.cache) do
		if instance.Parent then
			for key, value in pairs(record) do
				pcall(function()
					instance[key] = value
				end)
			end
		end
	end

	table.clear(NoLag.cache)

	if NoLag.saved.quality then
		pcall(function()
			settings().Rendering.QualityLevel = NoLag.saved.quality
		end)
	end

	local terrain = workspace:FindFirstChildOfClass("Terrain")
	if terrain and NoLag.saved.terrain then
		for key, value in pairs(NoLag.saved.terrain) do
			pcall(function()
				terrain[key] = value
			end)
		end
	end

	NoLag.saved = {}
	lighting.GlobalShadows = originalLighting.GlobalShadows
end

-- Crosshair drawings: filled disc, ring, center dot and a pool of line segments.
local crosshairFill = trackDrawing(createDrawing("Circle", { Filled = true, NumSides = 64, Visible = false }))
local crosshairRing = trackDrawing(createDrawing("Circle", { Filled = false, NumSides = 64, Visible = false }))
local crosshairDot = trackDrawing(createDrawing("Circle", { Filled = true, NumSides = 24, Visible = false }))
local crosshairLines = {}
local MAX_SEGMENTS = 8

for index = 1, MAX_SEGMENTS do
	crosshairLines[index] = trackDrawing(createDrawing("Line", { Visible = false }))
end

local function polar(angle, radius)
	local rad = math.rad(angle)
	return Vector2.new(math.cos(rad), math.sin(rad)) * radius
end

---Closed polygon edges around the center.
local function polygonSegments(sides, radius, startAngle)
	local segments = {}

	for index = 0, sides - 1 do
		local a = polar(startAngle + index * 360 / sides, radius)
		local b = polar(startAngle + (index + 1) * 360 / sides, radius)
		table.insert(segments, { a, b })
	end

	return segments
end

---Build the line segments (offsets from the center) for a crosshair style.
function Misc.buildSegments(style, gap, size, rotation)
	local segments = {}

	if style == "Classic" or style == "Target" or style == "X Cross" or style == "T Shape" then
		local base = rotation + (style == "X Cross" and 45 or 0)

		for index = 0, 3 do
			if not (style == "T Shape" and index == 3) then
				table.insert(segments, { polar(base + index * 90, gap), polar(base + index * 90, gap + size) })
			end
		end
	elseif style == "Star" then
		for index = 0, 7 do
			local length = index % 2 == 0 and size or size * 0.55
			table.insert(segments, { polar(rotation + index * 45, gap), polar(rotation + index * 45, gap + length) })
		end
	elseif style == "Diamond" then
		segments = polygonSegments(4, gap + size, rotation)
	elseif style == "Square" then
		segments = polygonSegments(4, gap + size, rotation + 45)
	elseif style == "Triangle" then
		segments = polygonSegments(3, gap + size, rotation - 90)
	elseif style == "Arrows" then
		for index = 0, 3 do
			local angle = rotation + index * 90
			local tip = polar(angle, gap)
			table.insert(segments, { tip, tip + polar(angle + 180 - 40, size) })
			table.insert(segments, { tip, tip + polar(angle + 180 + 40, size) })
		end
	end

	return segments
end

function Misc.getPing()
	local ok, value = pcall(function()
		return statsService.Network.ServerStatsItem["Data Ping"]:GetValue()
	end)

	if ok and value then
		return math.floor(value)
	end

	return math.floor(localPlayer:GetNetworkPing() * 1000)
end

function Misc.updateCrosshair(deltaTime)
	local misc = Config.misc
	local center = currentCamera.ViewportSize / 2
	local on = misc.crosshair
	local style = misc.crosshairStyle

	if misc.crosshairSpin then
		Misc.spin = (Misc.spin + misc.crosshairSpinSpeed * (deltaTime or 0)) % 360
	end

	local showCross = style ~= "Circle" and style ~= "Dot" and misc.crosshairCross
	local showRing = misc.crosshairRing or style == "Circle" or style == "Target"
	local showDot = misc.crosshairDot or style == "Dot"

	local crossColor = modeColor(misc.crosshairColorMode, misc.crosshairColor, misc.crosshairColorB, 0)
	local ringColor = modeColor(misc.crosshairRingMode, misc.crosshairRingColor, misc.crosshairColorB, 0.33)
	local fillColor = modeColor(misc.crosshairFillMode, misc.crosshairFillColor, misc.crosshairColorB, 0.66)

	local segments = showCross and Misc.buildSegments(style, misc.crosshairGap, misc.crosshairSize, misc.crosshairRotation + Misc.spin) or {}

	-- Shared with the menu preview.
	Misc.cross = { segments = segments, ring = showRing, fill = misc.crosshairFill, dot = showDot, crossColor = crossColor, ringColor = ringColor, fillColor = fillColor }

	crosshairFill.Visible = on and misc.crosshairFill
	crosshairFill.Position = center
	crosshairFill.Radius = misc.crosshairRadius
	crosshairFill.Color = fillColor
	crosshairFill.Transparency = misc.crosshairFillOpacity

	crosshairRing.Visible = on and showRing
	crosshairRing.Position = center
	crosshairRing.Radius = misc.crosshairRadius
	crosshairRing.Color = ringColor
	crosshairRing.Thickness = misc.crosshairRingThickness

	crosshairDot.Visible = on and showDot
	crosshairDot.Position = center
	crosshairDot.Radius = misc.crosshairDotSize
	crosshairDot.Color = crossColor

	for index, line in ipairs(crosshairLines) do
		local segment = segments[index]
		line.Visible = on and segment ~= nil

		if segment then
			line.From = center + segment[1]
			line.To = center + segment[2]
			line.Color = crossColor
			line.Thickness = misc.crosshairThickness
		end
	end
end

function Misc.updateCamera()
	if Config.misc.customFov then
		currentCamera.FieldOfView = Config.misc.fieldOfView
	end
end

local function getCharacterParts()
	local character = localPlayer.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	return character, root, humanoid
end

function Misc.updateSpeed(deltaTime)
	if not Config.misc.speed then
		return
	end

	local _, root, humanoid = getCharacterParts()

	if root and humanoid and humanoid.MoveDirection.Magnitude > 0 then
		root.CFrame = root.CFrame + humanoid.MoveDirection * Config.misc.speedAmount * deltaTime
	end
end

function Misc.updateFly()
	if not Config.misc.fly or userInputService:GetFocusedTextBox() then
		return
	end

	local _, root, humanoid = getCharacterParts()
	if not root then
		return
	end

	local look = currentCamera.CFrame
	local direction = Vector3.new(0, 0, 0)

	if isMobile and humanoid then
		direction = humanoid.MoveDirection
	else
		if userInputService:IsKeyDown(Enum.KeyCode.W) then direction += look.LookVector end
		if userInputService:IsKeyDown(Enum.KeyCode.S) then direction -= look.LookVector end
		if userInputService:IsKeyDown(Enum.KeyCode.D) then direction += look.RightVector end
		if userInputService:IsKeyDown(Enum.KeyCode.A) then direction -= look.RightVector end
		if userInputService:IsKeyDown(Enum.KeyCode.Space) then direction += Vector3.new(0, 1, 0) end
		if userInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction -= Vector3.new(0, 1, 0) end
	end

	root.AssemblyLinearVelocity = direction.Magnitude > 0 and direction.Unit * Config.misc.flySpeed or Vector3.new(0, 0, 0)
end

function Misc.updateNoclip()
	if not Config.misc.noclip then
		return
	end

	local character = localPlayer.Character
	if not character then
		return
	end

	for _, descendant in ipairs(character:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.CanCollide = false
		end
	end
end

---Apply a value while a toggle is on and restore the original when it turns off.
local function applyOverride(key, enabled, getter, setter, value)
	if enabled then
		if Misc.orig[key] == nil then
			Misc.orig[key] = getter()
		end

		setter(value)
	elseif Misc.orig[key] ~= nil then
		setter(Misc.orig[key])
		Misc.orig[key] = nil
	end
end

---Walk speed, jump power, gravity, zoom, bunny hop and spinbot.
function Misc.updateCharacter(deltaTime)
	local misc = Config.misc
	local _, root, humanoid = getCharacterParts()

	if humanoid then
		applyOverride("walk", misc.walkSpeed, function() return humanoid.WalkSpeed end, function(v) humanoid.WalkSpeed = v end, misc.walkSpeedValue)
		applyOverride("jump", misc.jumpPower, function() return humanoid.JumpPower end, function(v) humanoid.UseJumpPower = true humanoid.JumpPower = v end, misc.jumpPowerValue)

		if misc.bhop and not userInputService:GetFocusedTextBox() and userInputService:IsKeyDown(Enum.KeyCode.Space) and humanoid.FloorMaterial ~= Enum.Material.Air then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end

	applyOverride("gravity", misc.gravity, function() return workspace.Gravity end, function(v) workspace.Gravity = v end, misc.gravityValue)
	applyOverride("zoom", misc.maxZoom, function() return localPlayer.CameraMaxZoomDistance end, function(v) localPlayer.CameraMaxZoomDistance = v end, misc.maxZoomValue)

	if misc.spinbot and root then
		root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(misc.spinSpeed * 18) * deltaTime, 0)
	end
end

function Misc.restoreAll()
	local _, _, humanoid = getCharacterParts()

	if Misc.orig.walk and humanoid then humanoid.WalkSpeed = Misc.orig.walk end
	if Misc.orig.jump and humanoid then humanoid.JumpPower = Misc.orig.jump end
	if Misc.orig.gravity then workspace.Gravity = Misc.orig.gravity end
	if Misc.orig.zoom then localPlayer.CameraMaxZoomDistance = Misc.orig.zoom end

	table.clear(Misc.orig)
end

---Click while the left mouse button is held.
function Misc.updateAutoClicker()
	local misc = Config.misc
	if not misc.autoClicker or userInputService:GetFocusedTextBox() then
		return
	end

	if not userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
		return
	end

	local now = os.clock()
	if now - Misc.clickAt >= 1 / misc.autoClickerCps then
		Misc.clickAt = now
		clickMouse()
	end
end

function Misc.serverHop()
	local response = request({
		Url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100", game.PlaceId),
		Method = "GET",
	})

	if not response or not response.Success then
		return notify("Server Hop", "Server list request failed.", THEME.bad)
	end

	local ok, data = pcall(function()
		return httpService:JSONDecode(response.Body)
	end)

	if not ok or not data or not data.data then
		return notify("Server Hop", "Could not read server list.", THEME.bad)
	end

	local servers = {}
	for _, server in ipairs(data.data) do
		if server.id ~= game.JobId and server.playing < server.maxPlayers then
			table.insert(servers, server.id)
		end
	end

	if #servers == 0 then
		return notify("Server Hop", "No other servers found.", THEME.bad)
	end

	teleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(#servers)], localPlayer)
end

function Misc.applyFpsCap()
	local misc = Config.misc

	if setfpscap then
		setfpscap(misc.fpsCap and misc.fpsCapValue or 60)
	end
end

--------------------------------------------------------------------------------
-- Top HUD (FPS and ping) and slogan
--------------------------------------------------------------------------------

local hud = new("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 12), Size = UDim2.fromOffset(250, 30), BackgroundColor3 = THEME.bg, BorderSizePixel = 0 }, screenGui)
corner(hud, 15)
glowStroke(hud)

new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 0), Size = UDim2.fromOffset(64, 30), Font = Enum.Font.GothamBlack, TextSize = 12, RichText = true, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = THEME.text, Text = '<font color="#ff3c82"><u>vexora</u></font>' }, hud)
new("Frame", { Position = UDim2.fromOffset(82, 7), Size = UDim2.fromOffset(1, 16), BackgroundColor3 = THEME.line, BorderSizePixel = 0 }, hud)
new("Frame", { Position = UDim2.fromOffset(166, 7), Size = UDim2.fromOffset(1, 16), BackgroundColor3 = THEME.line, BorderSizePixel = 0 }, hud)

local hudFps = new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(88, 0), Size = UDim2.fromOffset(76, 30), Font = Enum.Font.GothamBold, TextSize = 12, RichText = true, TextColor3 = THEME.text, Text = "" }, hud)
local hudPing = new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(172, 0), Size = UDim2.fromOffset(74, 30), Font = Enum.Font.GothamBold, TextSize = 12, RichText = true, TextColor3 = THEME.text, Text = "" }, hud)

-- Slogan pill, top right.
local sloganFrame = new("Frame", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 12), Size = UDim2.fromOffset(226, 30), BackgroundColor3 = THEME.bg, BorderSizePixel = 0 }, screenGui)
corner(sloganFrame, 15)
glowStroke(sloganFrame)
makeLogo(sloganFrame, 26, UDim2.fromOffset(6, 2), Vector2.zero)
local sloganLabel = new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(32, 0), Size = UDim2.new(1, -38, 1, 0), Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = rgb(255, 255, 255), Text = SLOGAN }, sloganFrame)
local sloganGradient = gradient(sloganLabel, { rgb(255, 190, 220), rgb(255, 110, 175), rgb(255, 190, 220) }, 0)

--------------------------------------------------------------------------------
-- Main window
--------------------------------------------------------------------------------

local uiRefreshers = {}

function Vexora.refreshUi()
	for _, render in ipairs(uiRefreshers) do
		render()
	end
end

local root = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(MENU_WIDTH, MENU_HEIGHT), BackgroundTransparency = 1, Visible = false }, screenGui)
local fitScale = new("UIScale", {}, root)

local main = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1), BackgroundColor3 = THEME.bg, BorderSizePixel = 0 }, root)
corner(main, 10)
stroke(main, THEME.line, 1, 0.3)
local menuScale = new("UIScale", { Scale = 1 }, main)

---Scale the whole menu down so it always fits phones and small windows.
local function updateFit()
	local viewport = currentCamera.ViewportSize
	fitScale.Scale = math.min(1, (viewport.X - 16) / MENU_WIDTH, (viewport.Y - 16) / MENU_HEIGHT)
end

updateFit()

function Misc.updateHud()
	hud.Visible = Config.misc.hud
	sloganGradient.Offset = Vector2.new(math.sin(os.clock()) * 0.35, 0)

	Misc.frames += 1
	local now = os.clock()
	if now - Misc.lastFps < 0.5 then
		return
	end

	Misc.fps = math.floor(Misc.frames / (now - Misc.lastFps))
	Misc.frames = 0
	Misc.lastFps = now
	updateFit()

	local ping = Misc.getPing()
	local fpsColor = Misc.fps >= 55 and THEME.good or (Misc.fps >= 30 and rgb(255, 200, 70) or THEME.bad)
	local pingColor = ping <= 80 and THEME.good or (ping <= 150 and rgb(255, 200, 70) or THEME.bad)

	hudFps.Text = string.format('<font color="#%s">●</font> %d FPS', fpsColor:ToHex(), Misc.fps)
	hudPing.Text = string.format('<font color="#%s">●</font> %d ms', pingColor:ToHex(), ping)
end

-- Sidebar.
local sidebar = new("Frame", { Size = UDim2.new(0, 170, 1, -26), BackgroundColor3 = THEME.side, BorderSizePixel = 0 }, main)
corner(sidebar, 10)
new("Frame", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, 1, 1, 0), BackgroundColor3 = THEME.line, BackgroundTransparency = 0.5, BorderSizePixel = 0 }, sidebar)

local logoArea = new("Frame", { Size = UDim2.new(1, 0, 0, 104), BackgroundTransparency = 1 }, sidebar)
makeLogo(logoArea, 74, UDim2.new(0.5, 0, 0, 4), Vector2.new(0.5, 0))
new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 78), Size = UDim2.new(1, 0, 0, 24), Font = Enum.Font.GothamBlack, TextSize = 18, RichText = true, TextColor3 = THEME.text, Text = '<font color="#ff3c82"><u>vexora</u></font>.scripts' }, logoArea)

local sideList = new("ScrollingFrame", { Position = UDim2.fromOffset(0, 108), Size = UDim2.new(1, 0, 1, -114), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y }, sidebar)
new("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, sideList)
new("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, sideList)

-- Content area.
local content = new("Frame", { Position = UDim2.fromOffset(170, 0), Size = UDim2.new(1, -170, 1, -26), BackgroundTransparency = 1 }, main)
local tabBar = new("Frame", { Size = UDim2.new(1, 0, 0, 42), BackgroundTransparency = 1 }, content)
new("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = THEME.line, BackgroundTransparency = 0.5, BorderSizePixel = 0 }, tabBar)

local closeButton = new("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(26, 26), BackgroundColor3 = THEME.row, BorderSizePixel = 0, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = THEME.subtext, Text = "✕", AutoButtonColor = false }, tabBar)
corner(closeButton, 7)

local pagesHolder = new("Frame", { Position = UDim2.fromOffset(0, 46), Size = UDim2.new(1, 0, 1, -46), BackgroundTransparency = 1, ClipsDescendants = true }, content)

-- Footer.
local footer = new("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = THEME.side, BorderSizePixel = 0 }, main)
corner(footer, 10)
new("Frame", { Size = UDim2.new(1, 0, 0, 10), BackgroundColor3 = THEME.side, BorderSizePixel = 0 }, footer)
new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(0.5, 0, 1, 0), Font = Enum.Font.GothamMedium, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = THEME.subtext, Text = SLOGAN }, footer)
new("TextLabel", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 0), Size = UDim2.new(0.5, 0, 1, 0), Font = Enum.Font.GothamMedium, TextSize = 11, RichText = true, TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = THEME.subtext, Text = 'lifetime, <font color="#ff3c82">vexora.scripts</font>' }, footer)

-- Dragging, sliders and pickers share the global input listeners.
local dragging, dragStart, startPosition = false, nil, nil
local activeDrag = nil

---Convert an input position into screen coordinates that match GuiObject.AbsolutePosition.
local function toScreen(position)
	return Vector2.new(position.X, position.Y) + guiService:GetGuiInset()
end

local function isPress(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

local function makeDraggable(handle)
	connect(handle.InputBegan, function(input)
		if isPress(input) then
			dragging = true
			dragStart = input.Position
			startPosition = root.Position
		end
	end)
end

makeDraggable(tabBar)
makeDraggable(logoArea)

connect(userInputService.InputChanged, function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	if dragging then
		local delta = input.Position - dragStart
		root.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
	end

	if activeDrag then
		activeDrag(toScreen(input.Position))
	end
end)

connect(userInputService.InputEnded, function(input)
	if isPress(input) then
		dragging = false
		activeDrag = nil
	end
end)

-- Popups (dropdown lists and the color picker) live above everything else.
local popup = { backdrop = nil }

local function closePopup()
	if popup.backdrop then
		popup.backdrop:Destroy()
		popup.backdrop = nil
	end
end

local function openBackdrop()
	closePopup()

	local backdrop = new("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 50 }, screenGui)
	backdrop.MouseButton1Click:Connect(closePopup)
	popup.backdrop = backdrop
	return backdrop
end

---Place a popup next to an anchor without leaving the screen, then fade it in.
local function placePopup(frame, anchor, width, height)
	local viewport = screenGui.AbsoluteSize
	local anchorPos, anchorSize = anchor.AbsolutePosition, anchor.AbsoluteSize
	local x = math.clamp(anchorPos.X + anchorSize.X - width, 4, math.max(4, viewport.X - width - 4))
	local y = anchorPos.Y + anchorSize.Y + 4

	if y + height > viewport.Y - 4 then
		y = math.max(4, anchorPos.Y - height - 4)
	end

	frame.Position = UDim2.fromOffset(x, y + 6)
	tweenService:Create(frame, TweenInfo.new(0.16, Enum.EasingStyle.Quad), { Position = UDim2.fromOffset(x, y) }):Play()
end

local function openDropdown(anchor, options, current, onPick)
	local backdrop = openBackdrop()
	local width = math.max(160, anchor.AbsoluteSize.X * 0.45)
	local height = math.min(#options * 26 + 8, 220)

	local list = new("ScrollingFrame", { Size = UDim2.fromOffset(width, height), BackgroundColor3 = THEME.panel, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = THEME.accent, CanvasSize = UDim2.fromOffset(0, #options * 26 + 8) }, backdrop)
	corner(list, 8)
	stroke(list, THEME.line, 1, 0.2)
	new("UIListLayout", { Padding = UDim.new(0, 0), SortOrder = Enum.SortOrder.LayoutOrder }, list)
	new("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4) }, list)
	placePopup(list, anchor, width, height)

	for index, option in ipairs(options) do
		local item = new("TextButton", { Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = THEME.accent, BackgroundTransparency = 1, AutoButtonColor = false, Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = option == current and THEME.accent or THEME.text, Text = tostring(option), LayoutOrder = index }, list)

		item.MouseEnter:Connect(function()
			tweenService:Create(item, TweenInfo.new(0.12), { BackgroundTransparency = 0.8 }):Play()
		end)
		item.MouseLeave:Connect(function()
			tweenService:Create(item, TweenInfo.new(0.12), { BackgroundTransparency = 1 }):Play()
		end)
		item.MouseButton1Click:Connect(function()
			closePopup()
			onPick(option)
		end)
	end
end

local RAINBOW = ColorSequence.new({
	ColorSequenceKeypoint.new(0, rgb(255, 0, 0)), ColorSequenceKeypoint.new(0.17, rgb(255, 255, 0)), ColorSequenceKeypoint.new(0.33, rgb(0, 255, 0)),
	ColorSequenceKeypoint.new(0.5, rgb(0, 255, 255)), ColorSequenceKeypoint.new(0.67, rgb(0, 0, 255)), ColorSequenceKeypoint.new(0.83, rgb(255, 0, 255)), ColorSequenceKeypoint.new(1, rgb(255, 0, 0)),
})

---Open an HSV color picker bound to tbl[key].
local function openColorPicker(anchor, tbl, key, onChange)
	local backdrop = openBackdrop()
	local width, height = 196, 186

	local frame = new("Frame", { Size = UDim2.fromOffset(width, height), BackgroundColor3 = THEME.panel, BorderSizePixel = 0 }, backdrop)
	corner(frame, 10)
	stroke(frame, THEME.line, 1, 0.2)
	placePopup(frame, anchor, width, height)

	-- Swallow clicks so the backdrop does not close the picker.
	new("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false }, frame)

	local hue, saturation, value = tbl[key]:ToHSV()

	local square = new("Frame", { Position = UDim2.fromOffset(10, 10), Size = UDim2.fromOffset(176, 116), BackgroundColor3 = Color3.fromHSV(hue, 1, 1), BorderSizePixel = 0 }, frame)
	corner(square, 6)

	local white = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = rgb(255, 255, 255), BorderSizePixel = 0 }, square)
	corner(white, 6)
	new("UIGradient", { Transparency = NumberSequence.new(0, 1) }, white)

	local black = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = rgb(0, 0, 0), BorderSizePixel = 0 }, square)
	corner(black, 6)
	new("UIGradient", { Transparency = NumberSequence.new(1, 0), Rotation = 90 }, black)

	local cursor = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(10, 10), BackgroundTransparency = 1, BorderSizePixel = 0 }, square)
	corner(cursor, 5)
	stroke(cursor, rgb(255, 255, 255), 2, 0)

	local hueBar = new("Frame", { Position = UDim2.fromOffset(10, 134), Size = UDim2.fromOffset(176, 14), BackgroundColor3 = rgb(255, 255, 255), BorderSizePixel = 0 }, frame)
	corner(hueBar, 7)
	new("UIGradient", { Color = RAINBOW }, hueBar)

	local hueCursor = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(hue, 0.5), Size = UDim2.fromOffset(6, 18), BackgroundColor3 = rgb(255, 255, 255), BorderSizePixel = 0 }, hueBar)
	corner(hueCursor, 3)
	stroke(hueCursor, rgb(0, 0, 0), 1, 0.5)

	local hexLabel = new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 156), Size = UDim2.fromOffset(176, 20), Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = THEME.subtext, Text = "" }, frame)

	local function update()
		local color = Color3.fromHSV(hue, saturation, value)
		tbl[key] = color
		square.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
		cursor.Position = UDim2.fromScale(saturation, 1 - value)
		hueCursor.Position = UDim2.fromScale(hue, 0.5)
		hexLabel.Text = "#" .. color:ToHex():upper()

		if onChange then
			onChange(color)
		end

		Vexora.refreshUi()
	end

	local function dragSquare(position)
		saturation = math.clamp((position.X - square.AbsolutePosition.X) / square.AbsoluteSize.X, 0, 1)
		value = 1 - math.clamp((position.Y - square.AbsolutePosition.Y) / square.AbsoluteSize.Y, 0, 1)
		update()
	end

	local function dragHue(position)
		hue = math.clamp((position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
		update()
	end

	local squareHit = new("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 5 }, square)
	local hueHit = new("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 5 }, hueBar)

	squareHit.InputBegan:Connect(function(input)
		if isPress(input) then
			activeDrag = dragSquare
			dragSquare(toScreen(input.Position))
		end
	end)

	hueHit.InputBegan:Connect(function(input)
		if isPress(input) then
			activeDrag = dragHue
			dragHue(toScreen(input.Position))
		end
	end)

	update()
end

-- Categories, sub tabs and pages.
local categories = {}
local selectedCategory = nil

local function selectSub(category, sub)
	category.current = sub

	for _, other in ipairs(category.subs) do
		local on = other == sub
		other.page.Visible = on and category == selectedCategory
		other.underline.Visible = on
		tweenService:Create(other.label, TweenInfo.new(0.15), { TextColor3 = on and THEME.text or THEME.subtext }):Play()
	end

	-- Soft slide-in so tab changes feel smooth.
	if category == selectedCategory then
		sub.page.Position = UDim2.fromOffset(0, 10)
		tweenService:Create(sub.page, TweenInfo.new(0.22, Enum.EasingStyle.Quint), { Position = UDim2.fromOffset(0, 0) }):Play()
	end
end

local function selectCategory(category)
	selectedCategory = category

	for _, other in ipairs(categories) do
		local on = other == category
		other.strip.Visible = on
		other.bar.Visible = on
		tweenService:Create(other.button, TweenInfo.new(0.18), { BackgroundTransparency = on and 0 or 1 }):Play()
		tweenService:Create(other.nameLabel, TweenInfo.new(0.18), { TextColor3 = on and THEME.text or THEME.subtext }):Play()
		tweenService:Create(other.iconLabel, TweenInfo.new(0.18), { TextColor3 = on and THEME.accent or THEME.subtext }):Play()

		if not on then
			for _, sub in ipairs(other.subs) do
				sub.page.Visible = false
			end
		end
	end

	selectSub(category, category.current or category.subs[1])
end

local function addGroupLabel(text, order)
	new("TextLabel", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = THEME.text, Text = "  " .. text, LayoutOrder = order }, sideList)
end

local function createCategory(name, icon, order)
	local button = new("TextButton", { Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = THEME.row, BackgroundTransparency = 1, BorderSizePixel = 0, AutoButtonColor = false, Text = "", LayoutOrder = order }, sideList)
	corner(button, 8)

	local bar = new("Frame", { Position = UDim2.fromOffset(0, 8), Size = UDim2.fromOffset(3, 18), BackgroundColor3 = THEME.accent, BorderSizePixel = 0, Visible = false }, button)
	corner(bar, 2)

	local iconLabel = new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 0), Size = UDim2.fromOffset(26, 34), Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = THEME.subtext, Text = icon }, button)
	local nameLabel = new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(42, 0), Size = UDim2.new(1, -46, 1, 0), Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = THEME.subtext, Text = name }, button)

	local strip = new("Frame", { Size = UDim2.new(1, -50, 1, 0), BackgroundTransparency = 1, Visible = false }, tabBar)
	new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder }, strip)
	new("UIPadding", { PaddingLeft = UDim.new(0, 10) }, strip)

	local category = { name = name, button = button, bar = bar, iconLabel = iconLabel, nameLabel = nameLabel, strip = strip, subs = {}, current = nil }
	table.insert(categories, category)

	button.MouseButton1Click:Connect(function()
		closePopup()
		selectCategory(category)
	end)

	return category
end

---Create a sub tab with two columns. Returns the left and right column frames and the page.
local function createSub(category, name)
	local button = new("TextButton", { Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, AutoButtonColor = false, Text = "", LayoutOrder = #category.subs + 1 }, category.strip)
	new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, button)

	local label = new("TextLabel", { Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = THEME.subtext, Text = name }, button)
	local underline = new("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = THEME.accent, BorderSizePixel = 0, Visible = false }, button)

	local page = new("ScrollingFrame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = THEME.accent, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false }, pagesHolder)
	new("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 12), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 12) }, page)

	local columns = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 }, page)
	new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, columns)

	local function makeColumn(order)
		local column = new("Frame", { Size = UDim2.new(0.5, -5, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = order }, columns)
		new("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, column)
		return column
	end

	local left, right = makeColumn(1), makeColumn(2)
	local sub = { name = name, page = page, label = label, underline = underline }
	table.insert(category.subs, sub)

	button.MouseButton1Click:Connect(function()
		closePopup()
		selectSub(category, sub)
	end)

	return left, right, page
end

---Create a titled card inside a column and return its body.
local function createPanel(column, title, icon)
	local card = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = THEME.panel, BorderSizePixel = 0 }, column)
	corner(card, 8)
	stroke(card, THEME.line, 1, 0.6)
	new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, card)

	local header = new("Frame", { Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, LayoutOrder = 0 }, card)
	new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 0), Size = UDim2.fromOffset(22, 32), Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = THEME.accent, Text = icon or "▸" }, header)
	new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(34, 0), Size = UDim2.new(1, -40, 1, 0), Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = THEME.text, Text = title }, header)
	new("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = THEME.accent, BackgroundTransparency = 0.45, BorderSizePixel = 0 }, header)

	local body = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 1 }, card)
	new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, body)
	new("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, body)

	return body
end

-- Controls.
local function addRowLabel(row, text, widthOffset)
	return new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(2, 0), Size = UDim2.new(1, -widthOffset, 1, 0), Font = Enum.Font.GothamMedium, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = THEME.text, Text = text }, row)
end

local function addSwatch(row, tbl, key, offset, onChange)
	local swatch = new("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -offset, 0.5, 0), Size = UDim2.fromOffset(18, 18), BackgroundColor3 = tbl[key], BorderSizePixel = 0, Text = "", AutoButtonColor = false }, row)
	corner(swatch, 5)
	stroke(swatch, rgb(255, 255, 255), 1, 0.7)

	table.insert(uiRefreshers, function()
		swatch.BackgroundColor3 = tbl[key]
	end)

	swatch.MouseButton1Click:Connect(function()
		openColorPicker(swatch, tbl, key, onChange)
	end)

	return swatch
end

---Toggle row with a switch and optional color swatches. swatches = { { tbl, key, onChange } }.
local function addToggle(panel, text, tbl, key, callback, swatches)
	local row = new("TextButton", { Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = THEME.row, BackgroundTransparency = 1, Text = "", AutoButtonColor = false }, panel)
	corner(row, 6)
	addRowLabel(row, text, 120)

	local switch = new("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -4, 0.5, 0), Size = UDim2.fromOffset(40, 20), BackgroundColor3 = THEME.track, BorderSizePixel = 0 }, row)
	corner(switch, 10)
	local knob = new("Frame", { Position = UDim2.fromOffset(3, 3), Size = UDim2.fromOffset(14, 14), BackgroundColor3 = THEME.text, BorderSizePixel = 0 }, switch)
	corner(knob, 7)

	local function render(animated)
		local info = TweenInfo.new(animated and 0.18 or 0, Enum.EasingStyle.Quint)
		local on = tbl[key]
		tweenService:Create(switch, info, { BackgroundColor3 = on and THEME.accent or THEME.track }):Play()
		tweenService:Create(knob, info, { Position = on and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3) }):Play()
	end

	render(false)
	table.insert(uiRefreshers, function()
		render(false)
	end)

	for index, info in ipairs(swatches or {}) do
		addSwatch(row, info[1], info[2], 54 + (index - 1) * 24, info[3])
	end

	row.MouseEnter:Connect(function()
		tweenService:Create(row, TweenInfo.new(0.12), { BackgroundTransparency = 0.6 }):Play()
	end)
	row.MouseLeave:Connect(function()
		tweenService:Create(row, TweenInfo.new(0.12), { BackgroundTransparency = 1 }):Play()
	end)

	row.MouseButton1Click:Connect(function()
		tbl[key] = not tbl[key]
		render(true)

		if callback then
			callback(tbl[key])
		end
	end)
end

---Full width bar slider with the value written inside it.
local function addSlider(panel, text, tbl, key, minValue, maxValue, step, callback, suffix)
	local row = new("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1 }, panel)
	local track = new("Frame", { Position = UDim2.fromOffset(0, 2), Size = UDim2.new(1, 0, 1, -4), BackgroundColor3 = THEME.track, BorderSizePixel = 0 }, row)
	corner(track, 4)

	local fill = new("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = rgb(255, 255, 255), BorderSizePixel = 0 }, track)
	corner(fill, 4)
	gradient(fill, { THEME.accent3, THEME.accent2 }, 0)

	local label = new("TextLabel", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = rgb(255, 255, 255), TextStrokeTransparency = 0.55, ZIndex = 3 }, track)
	local hit = new("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 5 }, track)

	local function render()
		local alpha = math.clamp((tbl[key] - minValue) / (maxValue - minValue), 0, 1)
		tweenService:Create(fill, TweenInfo.new(0.08), { Size = UDim2.fromScale(alpha, 1) }):Play()
		label.Text = text .. ": " .. formatNumber(tbl[key]) .. (suffix or "")
	end

	render()
	table.insert(uiRefreshers, render)

	local function setFromPosition(position)
		local alpha = math.clamp((position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		local value = minValue + (maxValue - minValue) * alpha
		value = math.clamp(math.floor(value / step + 0.5) * step, minValue, maxValue)

		if value == tbl[key] then
			return
		end

		tbl[key] = value
		render()

		if callback then
			callback(value)
		end
	end

	hit.InputBegan:Connect(function(input)
		if isPress(input) then
			activeDrag = setFromPosition
			setFromPosition(toScreen(input.Position))
		end
	end)
end

---Dropdown row: click to open a list.
local function addDropdown(panel, text, tbl, key, options, callback)
	local row = new("TextButton", { Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, Text = "", AutoButtonColor = false }, panel)
	addRowLabel(row, text, 160)

	local valueLabel = new("TextLabel", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -2, 0, 0), Size = UDim2.fromOffset(150, 28), Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = THEME.subtext }, row)

	local function render()
		valueLabel.Text = tostring(tbl[key]) .. "  ⌄"
	end

	render()
	table.insert(uiRefreshers, render)

	row.MouseButton1Click:Connect(function()
		openDropdown(row, options, tbl[key], function(option)
			tbl[key] = option
			render()

			if callback then
				callback(option)
			end
		end)
	end)
end

local function addColor(panel, text, tbl, key, onChange)
	local row = new("Frame", { Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1 }, panel)
	addRowLabel(row, text, 40)
	addSwatch(row, tbl, key, 4, onChange)
end

local function addButton(panel, text, callback)
	local row = new("TextButton", { Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = THEME.row, BorderSizePixel = 0, AutoButtonColor = false, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = THEME.text, Text = text }, panel)
	corner(row, 6)

	row.MouseEnter:Connect(function()
		tweenService:Create(row, TweenInfo.new(0.15), { BackgroundColor3 = THEME.rowHover }):Play()
	end)
	row.MouseLeave:Connect(function()
		tweenService:Create(row, TweenInfo.new(0.15), { BackgroundColor3 = THEME.row }):Play()
	end)
	row.MouseButton1Click:Connect(callback)
end

local function addTextbox(panel, text, tbl, key, placeholder, callback)
	local row = new("Frame", { Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1 }, panel)
	addRowLabel(row, text, 120)

	local holder = new("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -2, 0.5, 0), Size = UDim2.fromOffset(110, 22), BackgroundColor3 = THEME.row, BorderSizePixel = 0 }, row)
	corner(holder, 5)

	local box = new("TextBox", { BackgroundTransparency = 1, Size = UDim2.new(1, -10, 1, 0), Position = UDim2.fromOffset(5, 0), Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = THEME.text, PlaceholderText = placeholder, PlaceholderColor3 = THEME.subtext, Text = tbl[key], ClearTextOnFocus = false }, holder)

	box.FocusLost:Connect(function()
		tbl[key] = (box.Text:gsub("%D", ""))
		box.Text = tbl[key]

		if callback then
			callback(tbl[key])
		end
	end)
end

-- Menu visibility with a soft scale animation.
local menuVisible = true
local menuToken = 0

local function setMenuVisible(visible)
	menuVisible = visible
	menuToken += 1
	local token = menuToken
	closePopup()

	if visible then
		menuScale.Scale = 0.9
		root.Visible = true
		tweenService:Create(menuScale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
		return
	end

	tweenService:Create(menuScale, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { Scale = 0.9 }):Play()
	task.delay(0.15, function()
		if token == menuToken then
			root.Visible = false
		end
	end)
end

closeButton.MouseButton1Click:Connect(function()
	setMenuVisible(false)
end)

connect(userInputService.InputBegan, function(input, processed)
	if processed then
		return
	end

	if input.KeyCode == MENU_KEYS[Config.misc.menuKey] then
		setMenuVisible(not menuVisible)
		return
	end

	-- Ctrl + click teleport.
	if Config.misc.clickTp and input.UserInputType == Enum.UserInputType.MouseButton1 and userInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		local _, rootPart = getCharacterParts()
		local target = mouse.Hit

		if rootPart and target then
			rootPart.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0))
		end
	end
end)

-- Floating logo button to open the menu on touch devices.
local menuButton = new("TextButton", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 10, 0.5, 0), Size = UDim2.fromOffset(46, 46), BackgroundColor3 = THEME.bg, BorderSizePixel = 0, AutoButtonColor = false, Text = "" }, screenGui)
corner(menuButton, 23)
glowStroke(menuButton)
makeLogo(menuButton, 38, UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5))

menuButton.MouseButton1Click:Connect(function()
	setMenuVisible(not menuVisible)
end)

--------------------------------------------------------------------------------
-- Pages
--------------------------------------------------------------------------------

local combat = Config.combat
local esp = Config.esp
local world = Config.world
local live = world.live
local misc = Config.misc

-- Seed the live values so every slider and swatch has something to render.
for key, value in pairs(ENVIRONMENTS.Default) do
	live[key] = value
end

local function onLiveChanged()
	World.pushLive()
end

local function onSkyChanged()
	World.applySky()
end

addGroupLabel("game", 1)
local combatCategory = createCategory("combat", "🎯", 2)
local visualsCategory = createCategory("visuals", "👁", 3)
local worldCategory = createCategory("world", "🌸", 4)
local miscCategory = createCategory("misc", "⚡", 5)
addGroupLabel("settings", 6)
local settingsCategory = createCategory("settings", "⚙", 7)

-- Combat: aim.
do
	local left, right = createSub(combatCategory, "aim")

	local aimbot = createPanel(left, "aimbot", "🎯")
	addToggle(aimbot, "enable - aimbot", combat, "aimbot")
	addDropdown(aimbot, "method", combat, "aimMethod", { "Camera", "Mouse" })
	addDropdown(aimbot, "aim key", combat, "aimKey", AIM_KEY_NAMES)
	addDropdown(aimbot, "target part", combat, "aimPart", PART_NAMES)
	addSlider(aimbot, "smoothing", combat, "smoothing", 0, 100, 1, nil, "%")
	addToggle(aimbot, "sticky target", combat, "stickyTarget")

	local fov = createPanel(right, "fov & checks", "◎")
	addSlider(fov, "aimbot fov", combat, "fov", 20, 600, 1, nil, "px")
	addToggle(fov, "draw outline", combat, "showFov", nil, { { combat, "fovColor" }, { combat, "fovColorB" } })
	addDropdown(fov, "outline color", combat, "fovColorMode", COLOR_MODES)
	addToggle(fov, "fill circle", combat, "fovFill", nil, { { combat, "fovFillColor" } })
	addDropdown(fov, "fill color", combat, "fovFillMode", COLOR_MODES)
	addSlider(fov, "fill opacity", combat, "fovFillOpacity", 0.05, 1, 0.05)
	addToggle(fov, "wall check", combat, "wallCheck")
	addToggle(fov, "team check", combat, "teamCheck")

	local prediction = createPanel(right, "prediction", "➤")
	addToggle(prediction, "enable - prediction", combat, "prediction")
	addSlider(prediction, "amount", combat, "predictionAmount", 0, 0.5, 0.01)
end

-- Combat: silent aim.
do
	local left, right = createSub(combatCategory, "silent aim")

	local silent = createPanel(left, "silent aim", "🔫")
	addToggle(silent, "enable - silent aim", combat, "silentAim")
	addDropdown(silent, "target part", combat, "silentPart", PART_NAMES)
	addToggle(silent, "random body part", combat, "silentRandom")
	addSlider(silent, "hitchance", combat, "hitChance", 1, 100, 1, nil, "%")
	addToggle(silent, "wall check", combat, "silentWallCheck")
	addToggle(silent, "remote redirect (shots)", combat, "remoteRedirect")

	local fov = createPanel(right, "fov settings", "◎")
	addSlider(fov, "silent fov", combat, "silentFov", 20, 800, 1, nil, "px")
	addToggle(fov, "draw circle", combat, "showSilentFov", nil, { { combat, "silentFovColor" } })
	addDropdown(fov, "circle color", combat, "silentFovMode", COLOR_MODES)
	addToggle(fov, "team check", combat, "teamCheck")
end

-- Combat: extras.
do
	local left, right = createSub(combatCategory, "extras")

	local trigger = createPanel(left, "triggerbot", "⚡")
	addToggle(trigger, "enable - triggerbot", combat, "triggerbot")
	addSlider(trigger, "delay", combat, "triggerDelay", 0, 500, 5, nil, "ms")
	addToggle(trigger, "head only", combat, "triggerHeadOnly")

	local auto = createPanel(left, "auto shoot", "✦")
	addToggle(auto, "enable - auto shoot", combat, "autoShoot")
	addSlider(auto, "delay", combat, "autoShootDelay", 0, 500, 5, nil, "ms")
	addSlider(auto, "fov", combat, "autoShootFov", 5, 400, 1, nil, "px")
	addToggle(auto, "wall check", combat, "autoShootWallCheck")

	local hitbox = createPanel(right, "hitbox expander", "▣")
	addToggle(hitbox, "enable - hitbox", combat, "hitbox")
	addDropdown(hitbox, "part", combat, "hitboxPart", PART_NAMES)
	addSlider(hitbox, "size", combat, "hitboxSize", 2, 25, 0.5)
	addSlider(hitbox, "transparency", combat, "hitboxTransparency", 0, 1, 0.05)
end

-- Visuals: esp.
do
	local left, right = createSub(visualsCategory, "esp")

	local targets = createPanel(left, "players & bots", "👁")
	addToggle(targets, "enable - esp", esp, "enabled")
	addToggle(targets, "boxes", esp, "boxes")
	addToggle(targets, "names", esp, "names")
	addToggle(targets, "distance", esp, "distance")
	addToggle(targets, "health bar", esp, "health")
	addToggle(targets, "tracers", esp, "tracers")
	addDropdown(targets, "tracer origin", esp, "tracerOrigin", TRACER_ORIGINS)

	local style = createPanel(right, "style", "🎨")
	addToggle(style, "chams", esp, "chams")
	addSlider(style, "chams fill", esp, "chamsFill", 0, 1, 0.05)
	addToggle(style, "hide teammates", esp, "teamCheck")
	addSlider(style, "max distance", esp, "maxDistance", 100, 5000, 50, nil, "m")
	addToggle(style, "rainbow", esp, "rainbow", nil, { { esp, "color" } })
end

-- Crosshair preview built from GUI frames so it shows the exact style, colors and animation.
local preview = { lines = {}, ready = false }

function Misc.buildPreview(panel)
	local stage = new("Frame", { Size = UDim2.new(1, 0, 0, 170), BackgroundColor3 = rgb(16, 11, 20), BorderSizePixel = 0, ClipsDescendants = true }, panel)
	corner(stage, 8)
	stroke(stage, THEME.line, 1, 0.5)
	gradient(stage, { rgb(34, 20, 38), rgb(14, 10, 18) }, 90)

	new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = THEME.line, BackgroundTransparency = 0.7, BorderSizePixel = 0 }, stage)
	new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(0, 1, 1, 0), BackgroundColor3 = THEME.line, BackgroundTransparency = 0.7, BorderSizePixel = 0 }, stage)
	new("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 4), Size = UDim2.fromOffset(120, 14), Font = Enum.Font.GothamBold, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = THEME.subtext, Text = "LIVE PREVIEW" }, stage)

	preview.fill = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), BorderSizePixel = 0 }, stage)
	corner(preview.fill, 999)

	preview.ring = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), BackgroundTransparency = 1, BorderSizePixel = 0 }, stage)
	corner(preview.ring, 999)
	preview.ringStroke = stroke(preview.ring, rgb(255, 255, 255), 1.5, 0)

	for index = 1, MAX_SEGMENTS do
		preview.lines[index] = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), BorderSizePixel = 0, Visible = false }, stage)
	end

	preview.dot = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), BorderSizePixel = 0 }, stage)
	corner(preview.dot, 999)

	preview.stage = stage
	preview.ready = true
end

function Misc.updatePreview()
	local state = Misc.cross
	if not (preview.ready and state and root.Visible and preview.stage.Visible and selectedCategory == visualsCategory) then
		return
	end

	local scale = 1.15
	local config = Config.misc
	local radius = config.crosshairRadius * scale

	preview.fill.Visible = state.fill
	preview.fill.Size = UDim2.fromOffset(radius * 2, radius * 2)
	preview.fill.BackgroundColor3 = state.fillColor
	preview.fill.BackgroundTransparency = 1 - config.crosshairFillOpacity

	preview.ring.Visible = state.ring
	preview.ring.Size = UDim2.fromOffset(radius * 2, radius * 2)
	preview.ringStroke.Color = state.ringColor
	preview.ringStroke.Thickness = config.crosshairRingThickness

	preview.dot.Visible = state.dot
	preview.dot.Size = UDim2.fromOffset(config.crosshairDotSize * 2 * scale, config.crosshairDotSize * 2 * scale)
	preview.dot.BackgroundColor3 = state.crossColor

	for index, line in ipairs(preview.lines) do
		local segment = state.segments[index]
		line.Visible = segment ~= nil

		if segment then
			local delta = segment[2] - segment[1]
			local middle = (segment[1] + segment[2]) / 2 * scale

			line.Size = UDim2.fromOffset(delta.Magnitude * scale + 1, math.max(config.crosshairThickness, 1))
			line.Position = UDim2.new(0.5, middle.X, 0.5, middle.Y)
			line.Rotation = math.deg(math.atan2(delta.Y, delta.X))
			line.BackgroundColor3 = state.crossColor
		end
	end
end

-- Visuals: crosshair.
do
	local left, right = createSub(visualsCategory, "crosshair")

	local shape = createPanel(left, "crosshair", "✚")
	addToggle(shape, "enable - crosshair", misc, "crosshair")
	addDropdown(shape, "style", misc, "crosshairStyle", CROSSHAIR_STYLES)
	addToggle(shape, "cross lines", misc, "crosshairCross", nil, { { misc, "crosshairColor" }, { misc, "crosshairColorB" } })
	addDropdown(shape, "cross color", misc, "crosshairColorMode", COLOR_MODES)
	addToggle(shape, "circle", misc, "crosshairRing", nil, { { misc, "crosshairRingColor" } })
	addDropdown(shape, "circle color", misc, "crosshairRingMode", COLOR_MODES)
	addToggle(shape, "fill inside circle", misc, "crosshairFill", nil, { { misc, "crosshairFillColor" } })
	addDropdown(shape, "inside color", misc, "crosshairFillMode", COLOR_MODES)
	addSlider(shape, "inside opacity", misc, "crosshairFillOpacity", 0, 1, 0.05)
	addToggle(shape, "center dot", misc, "crosshairDot")

	local size = createPanel(right, "size & style", "◈")
	addSlider(size, "circle size", misc, "crosshairRadius", 4, 60, 1)
	addSlider(size, "cross size", misc, "crosshairSize", 1, 40, 1)
	addSlider(size, "cross gap", misc, "crosshairGap", 0, 30, 1)
	addSlider(size, "cross thickness", misc, "crosshairThickness", 0.5, 5, 0.5)
	addSlider(size, "circle thickness", misc, "crosshairRingThickness", 0.5, 5, 0.5)
	addSlider(size, "rotation", misc, "crosshairRotation", 0, 90, 1, nil, "°")
	addSlider(size, "dot size", misc, "crosshairDotSize", 0.5, 6, 0.5)
	addToggle(size, "spin", misc, "crosshairSpin")
	addSlider(size, "spin speed", misc, "crosshairSpinSpeed", 10, 360, 10)

	-- Preview sits at the bottom of the right column so it stays visible next to the controls.
	local previewPanel = createPanel(right, "preview", "👁")
	Misc.buildPreview(previewPanel)
end

-- Visuals: hud.
do
	local left, right = createSub(visualsCategory, "hud")

	local overlay = createPanel(left, "overlay", "▤")
	addToggle(overlay, "fps / ping hud", misc, "hud")
	addToggle(overlay, "custom fov", misc, "customFov")
	addSlider(overlay, "field of view", misc, "fieldOfView", 30, 120, 1)

	local brand = createPanel(right, "slogan", "✦")
	addToggle(brand, "show slogan", { v = true }, "v", function(value)
		sloganFrame.Visible = value
	end)
end

-- World: environment.
do
	local left, right = createSub(worldCategory, "environment")

	local preset = createPanel(left, "presets", "🌅")
	addDropdown(preset, "environment", world, "environment", ENVIRONMENT_NAMES, function(value)
		World.select(value)
	end)
	addSlider(preset, "transition", world, "transition", 0.5, 10, 0.5, nil, "s")
	addToggle(preset, "auto weather", world, "autoWeather")
	addButton(preset, "reset to preset", function()
		World.select(world.environment, 0.8)
	end)

	local foggy = createPanel(left, "foggy preset", "🌫")
	addSlider(foggy, "fog density", world, "fogDensity", 0.1, 1, 0.05, function()
		if world.environment == "Foggy" then
			World.select("Foggy", 0.6)
		end
	end)
	addSlider(foggy, "fog blur", world, "fogBlur", 0, 24, 1, function()
		if world.environment == "Foggy" then
			World.select("Foggy", 0.6)
		end
	end)

	local overrides = createPanel(right, "overrides", "☀")
	addToggle(overrides, "lock time of day", world, "timeLock", onLiveChanged)
	addSlider(overrides, "time of day", world, "timeOfDay", 0, 24, 0.25)
	addToggle(overrides, "fullbright", world, "fullbright", onLiveChanged)
	addToggle(overrides, "no fog", world, "noFog", onLiveChanged)
	addToggle(overrides, "no shadows", world, "noShadows", function(value)
		if not value then
			lighting.GlobalShadows = originalLighting.GlobalShadows
		end
	end)
	addToggle(overrides, "lightning", world, "lightning")
end

-- World: color.
do
	local left, right = createSub(worldCategory, "color")

	local grade = createPanel(left, "color correction", "🎨")
	addColor(grade, "tint", live, "tint", onLiveChanged)
	addSlider(grade, "saturation", live, "sat", -1, 2, 0.05, onLiveChanged)
	addSlider(grade, "contrast", live, "con", -1, 1, 0.05, onLiveChanged)
	addSlider(grade, "brightness", live, "gb", -0.5, 0.5, 0.01, onLiveChanged)

	local bloom = createPanel(left, "bloom", "✨")
	addSlider(bloom, "intensity", live, "bloom", 0, 3, 0.05, onLiveChanged)
	addSlider(bloom, "size", live, "bsize", 0, 56, 1, onLiveChanged)
	addSlider(bloom, "threshold", live, "bthr", 0, 2, 0.05, onLiveChanged)

	local colors = createPanel(right, "world colors", "🌈")
	addColor(colors, "ambient", live, "amb", onLiveChanged)
	addColor(colors, "outdoor ambient", live, "out", onLiveChanged)
	addColor(colors, "colorshift top", live, "top", onLiveChanged)
	addColor(colors, "colorshift bottom", live, "bot", onLiveChanged)
	addColor(colors, "fog color", live, "fog", onLiveChanged)

	local effects = createPanel(right, "effects", "◐")
	addSlider(effects, "blur", live, "blur", 0, 24, 0.5, onLiveChanged)
	addSlider(effects, "sun rays", live, "rays", 0, 1, 0.01, onLiveChanged)
end

-- World: atmosphere.
do
	local left, right = createSub(worldCategory, "atmosphere")

	local air = createPanel(left, "atmosphere", "☁")
	addSlider(air, "density", live, "dens", 0, 1, 0.01, onLiveChanged)
	addSlider(air, "offset", live, "off", 0, 1, 0.01, onLiveChanged)
	addSlider(air, "haze", live, "haze", 0, 10, 0.1, onLiveChanged)
	addSlider(air, "glare", live, "glare", 0, 10, 0.1, onLiveChanged)
	addColor(air, "sky color", live, "acol", onLiveChanged)
	addColor(air, "sky decay (horizon)", live, "adec", onLiveChanged)

	local light = createPanel(right, "lighting", "💡")
	addSlider(light, "brightness", live, "br", 0, 6, 0.1, onLiveChanged)
	addSlider(light, "exposure", live, "exp", -2, 3, 0.05, onLiveChanged)
	addSlider(light, "clock time", live, "t", 0, 24, 0.1, onLiveChanged)
	addSlider(light, "fog start", live, "fogStart", 0, 2000, 10, onLiveChanged)
	addSlider(light, "fog end", live, "fogEnd", 50, 8000, 50, onLiveChanged)
end

-- World: weather.
do
	local left, right = createSub(worldCategory, "weather")

	local weatherPanel = createPanel(left, "weather", "🌧")
	addDropdown(weatherPanel, "type", world, "weather", WEATHER_NAMES, Weather.set)
	addSlider(weatherPanel, "density", world, "intensity", 10, 300, 5, Weather.applyTuning, "%")
	addSlider(weatherPanel, "particle size", world, "particleSize", 40, 300, 5, Weather.applyTuning, "%")
	addSlider(weatherPanel, "fall speed", world, "fallSpeed", 30, 250, 5, Weather.applyTuning, "%")
	addSlider(weatherPanel, "radius", world, "radius", 30, 250, 5, Weather.applyTuning, " studs")
	addSlider(weatherPanel, "height", world, "height", 10, 120, 1, nil, " studs")
	addToggle(weatherPanel, "fall around me", world, "nearPetals", function()
		Weather.set(world.weather)
	end)

	local wind = createPanel(right, "wind", "🍃")
	addSlider(wind, "wind strength", world, "windStrength", 0, 40, 1)
	addSlider(wind, "wind direction", world, "windDirection", 0, 360, 5, nil, "°")
	addToggle(wind, "lightning", world, "lightning")
end

-- World: sky.
do
	local left, right = createSub(worldCategory, "sky")

	local skyPanel = createPanel(left, "skybox", "🌌")
	addDropdown(skyPanel, "skybox", world, "skyMode", SKY_MODES, function()
		world.skyId = ""
		onSkyChanged()
	end)
	addTextbox(skyPanel, "custom skybox id", world, "skyId", "asset id", onSkyChanged)
	addButton(skyPanel, "clear custom skybox", function()
		world.skyId = ""
		Vexora.refreshUi()
		onSkyChanged()
	end)

	local skyColors = createPanel(left, "sky colors", "🎨")
	addColor(skyColors, "sky color", live, "acol", onLiveChanged)
	addColor(skyColors, "horizon color", live, "adec", onLiveChanged)
	addColor(skyColors, "top shift", live, "top", onLiveChanged)
	addColor(skyColors, "bottom shift", live, "bot", onLiveChanged)
	addSlider(skyColors, "sky density", live, "dens", 0, 1, 0.01, onLiveChanged)

	local celestial = createPanel(right, "celestial", "🌙")
	addSlider(celestial, "stars", live, "stars", 0, 20000, 250, onLiveChanged)
	addToggle(celestial, "sun & moon", live, "bodies", onSkyChanged)
	addSlider(celestial, "sun size", world, "sunSize", 2, 60, 1, onSkyChanged)
	addSlider(celestial, "moon size", world, "moonSize", 2, 60, 1, onSkyChanged)
end

-- World: effects.
do
	local left, right = createSub(worldCategory, "effects")

	local presets = createPanel(left, "quality presets", "✨")
	addDropdown(presets, "look", world, "effectPreset", EFFECT_PRESETS, function(value)
		if value == "None" then
			-- Return to the grading values of the current environment.
			local base = World.getPreset(world.environment)

			for _, key in ipairs({ "sat", "con", "gb", "tint", "bloom", "bsize", "bthr", "rays", "blur" }) do
				live[key] = base[key]
			end

			Vexora.refreshUi()
			World.tweenToLive(0.8)
			return
		end

		Effects.apply(value)
	end)
	addToggle(presets, "rainbow world tint", world, "rainbowTint", onLiveChanged)
	addSlider(presets, "tint speed", world, "rainbowTintSpeed", 0.02, 0.6, 0.02)

	local lens = createPanel(left, "lens & glow", "🔆")
	addSlider(lens, "bloom", live, "bloom", 0, 3, 0.05, onLiveChanged)
	addSlider(lens, "bloom size", live, "bsize", 0, 56, 1, onLiveChanged)
	addSlider(lens, "sun rays", live, "rays", 0, 1, 0.01, onLiveChanged)
	addSlider(lens, "atmosphere glare", live, "glare", 0, 10, 0.1, onLiveChanged)
	addSlider(lens, "soft blur", live, "blur", 0, 24, 0.5, onLiveChanged)

	local depth = createPanel(right, "depth of field", "◉")
	addToggle(depth, "enable - depth of field", world, "dof")
	addSlider(depth, "focus distance", world, "dofFocus", 5, 400, 5, nil, " studs")
	addSlider(depth, "focus radius", world, "dofRadius", 5, 300, 5, nil, " studs")
	addSlider(depth, "far blur", world, "dofFar", 0, 1, 0.05)
	addSlider(depth, "near blur", world, "dofNear", 0, 1, 0.05)

	local vignette = createPanel(right, "vignette", "◍")
	addToggle(vignette, "enable - vignette", world, "vignette", nil, { { world, "vignetteColor" } })
	addSlider(vignette, "strength", world, "vignetteOpacity", 0.05, 1, 0.05)
	addSlider(vignette, "size", world, "vignetteSize", 0.1, 0.8, 0.05)

	local filter = createPanel(right, "screen filter", "🎨")
	addToggle(filter, "enable - filter", world, "filter", nil, { { world, "filterColor" } })
	addSlider(filter, "strength", world, "filterOpacity", 0.05, 1, 0.05)

	local shadows = createPanel(left, "shadows", "◐")
	addToggle(shadows, "soft shadows", world, "softShadows", function(value)
		if not value then
			lighting.ShadowSoftness = originalLighting.ShadowSoftness
		end
	end)
	addSlider(shadows, "softness", world, "shadowSoftness", 0, 1, 0.05)
end

-- Misc: movement.
do
	local left, right = createSub(miscCategory, "movement")

	local movement = createPanel(left, "movement", "🏃")
	addToggle(movement, "speed (cframe)", misc, "speed")
	addSlider(movement, "speed amount", misc, "speedAmount", 1, 60, 1)
	addToggle(movement, "walk speed", misc, "walkSpeed")
	addSlider(movement, "walk speed value", misc, "walkSpeedValue", 16, 200, 1)
	addToggle(movement, "fly (wasd / stick)", misc, "fly")
	addSlider(movement, "fly speed", misc, "flySpeed", 10, 200, 5)

	local other = createPanel(right, "jumping & gravity", "◈")
	addToggle(other, "infinite jump", misc, "infiniteJump")
	addToggle(other, "bunny hop (hold space)", misc, "bhop")
	addToggle(other, "jump power", misc, "jumpPower")
	addSlider(other, "jump power value", misc, "jumpPowerValue", 50, 300, 5)
	addToggle(other, "gravity", misc, "gravity")
	addSlider(other, "gravity value", misc, "gravityValue", 0, 196, 2)
	addToggle(other, "noclip", misc, "noclip")
	addToggle(other, "anti afk", misc, "antiAfk")
end

-- Misc: tools.
do
	local left, right = createSub(miscCategory, "tools")

	local tools = createPanel(left, "tools", "🛠")
	addToggle(tools, "spinbot", misc, "spinbot")
	addSlider(tools, "spin speed", misc, "spinSpeed", 1, 100, 1)
	addToggle(tools, "ctrl + click teleport", misc, "clickTp")
	addToggle(tools, "auto clicker (hold lmb)", misc, "autoClicker")
	addSlider(tools, "clicks per second", misc, "autoClickerCps", 1, 40, 1)
	addToggle(tools, "unlock camera zoom", misc, "maxZoom")
	addSlider(tools, "max zoom", misc, "maxZoomValue", 20, 2000, 10)

	local actions = createPanel(right, "actions", "⚡")
	addButton(actions, "reset character", function()
		local _, _, humanoid = getCharacterParts()

		if humanoid then
			humanoid.Health = 0
		end
	end)
	addButton(actions, "copy position", function()
		local _, rootPart = getCharacterParts()

		if rootPart and setclipboard then
			local p = rootPart.Position
			pcall(setclipboard, string.format("Vector3.new(%.2f, %.2f, %.2f)", p.X, p.Y, p.Z))
			notify("Position", "Copied to clipboard.", THEME.good)
		end
	end)
	addButton(actions, "copy place id", function()
		if setclipboard then
			pcall(setclipboard, tostring(game.PlaceId))
			notify("Place Id", "Copied " .. game.PlaceId, THEME.good)
		end
	end)
	addButton(actions, "copy job id", function()
		if setclipboard then
			pcall(setclipboard, game.JobId)
			notify("Job Id", "Copied to clipboard.", THEME.good)
		end
	end)
end

-- Misc: performance.
do
	local left, right = createSub(miscCategory, "performance")

	local perf = createPanel(left, "performance", "⚡")
	addToggle(perf, "no lag mode", misc, "noLag", NoLag.set)
	addToggle(perf, "fps cap", misc, "fpsCap", Misc.applyFpsCap)
	addSlider(perf, "fps cap value", misc, "fpsCapValue", 30, 360, 10, Misc.applyFpsCap)
end

-- Settings.
do
	local left, right = createSub(settingsCategory, "general")

	local general = createPanel(left, "interface", "🖥")
	addDropdown(general, "menu key", misc, "menuKey", MENU_KEY_NAMES)
	addToggle(general, "menu button", misc, "mobileButton", function(value)
		menuButton.Visible = value
	end)

	local utility = createPanel(right, "utility", "🛠")
	addButton(utility, "copy discord invite", function()
		if setclipboard then
			pcall(setclipboard, DISCORD_LINK)
		end

		notify("Discord", "Invite copied to clipboard!", THEME.accent2)
	end)
	addButton(utility, "rejoin", function()
		teleportService:Teleport(game.PlaceId, localPlayer)
	end)
	addButton(utility, "server hop", function()
		task.spawn(Misc.serverHop)
	end)
	addButton(utility, "unload", function()
		Vexora.detach()
	end)
end

menuButton.Visible = misc.mobileButton
selectCategory(combatCategory)

--------------------------------------------------------------------------------
-- Main loops
--------------------------------------------------------------------------------

local function onRenderStepped(deltaTime)
	currentCamera = workspace.CurrentCamera

	runSafe("FovCircles", Combat.updateFovCircles)
	runSafe("SilentAim", Combat.updateSilentAim)
	runSafe("Esp", Esp.update)
	runSafe("Weather", Weather.update)
	runSafe("WorldOverrides", World.updateOverrides)
	runSafe("Hud", Misc.updateHud)
	runSafe("Crosshair", Misc.updateCrosshair, deltaTime)
	runSafe("Preview", Misc.updatePreview)
	runSafe("Camera", Misc.updateCamera)
end

local function onHeartbeat(deltaTime)
	runSafe("Triggerbot", Combat.updateTriggerbot)
	runSafe("AutoShoot", Combat.updateAutoShoot)
	runSafe("Hitboxes", Combat.updateHitboxes)
	runSafe("Speed", Misc.updateSpeed, deltaTime)
	runSafe("Fly", Misc.updateFly)
	runSafe("Character", Misc.updateCharacter, deltaTime)
	runSafe("AutoClicker", Misc.updateAutoClicker)
end

connect(runService.RenderStepped, onRenderStepped)
connect(runService.Heartbeat, onHeartbeat)
connect(runService.Stepped, function()
	runSafe("Noclip", Misc.updateNoclip)
end)

-- The aimbot runs right after the default camera so nothing overwrites it.
runService:BindToRenderStep(AIM_BIND_NAME, Enum.RenderPriority.Camera.Value + 1, function(deltaTime)
	currentCamera = workspace.CurrentCamera
	runSafe("Aimbot", Combat.updateAimbot, deltaTime)
end)

connect(userInputService.JumpRequest, function()
	if not Config.misc.infiniteJump then
		return
	end

	local _, _, humanoid = getCharacterParts()
	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

connect(localPlayer.Idled, function()
	if Config.misc.antiAfk then
		virtualUser:CaptureController()
		virtualUser:ClickButton2(Vector2.new())
	end
end)

-- Start tracking every player and bot, and build ESP for each.
Targets.onAdded = Esp.create
Targets.onRemoved = Esp.remove
Targets.start()

-- Random lightning flashes while enabled.
task.spawn(function()
	while Vexora.active do
		task.wait(math.random(40, 110) / 10)

		if Vexora.active and Config.world.lightning then
			World.flashLightning()
		end
	end
end)

---Disconnect everything, restore the game and remove all objects.
function Vexora.detach()
	if not Vexora.active then
		return
	end

	Vexora.active = false
	Vexora.silent.part = nil

	pcall(function()
		runService:UnbindFromRenderStep(AIM_BIND_NAME)
	end)

	for _, connection in ipairs(Vexora.connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end

	for _, drawing in ipairs(Vexora.drawings) do
		pcall(function()
			drawing:Remove()
		end)
	end

	Targets.stop()

	for model in pairs(Vexora.espObjects) do
		Esp.remove(model)
	end

	for part in pairs(Vexora.hitboxCache) do
		Combat.restoreHitbox(part)
	end

	pcall(Misc.restoreAll)
	NoLag.set(false)
	Weather.retire()
	cancelTweens()

	for key, value in pairs(originalLighting) do
		pcall(function()
			lighting[key] = value
		end)
	end

	if not ownsAtmosphere then
		for key, value in pairs(originalAtmosphere) do
			pcall(function()
				atmosphere[key] = value
			end)
		end
	end

	if not ownsSky then
		for key, value in pairs(originalSky.faces) do
			pcall(function()
				sky[key] = value
			end)
		end

		for _, key in ipairs({ "StarCount", "CelestialBodiesShown", "SunAngularSize", "MoonAngularSize" }) do
			pcall(function()
				sky[key] = originalSky[key]
			end)
		end
	end

	for _, instance in ipairs(Vexora.instances) do
		pcall(function()
			instance:Destroy()
		end)
	end

	if Config.misc.fpsCap and setfpscap then
		setfpscap(60)
	end

	screenGui:Destroy()

	if shared.Vexora == Vexora then
		shared.Vexora = nil
	end
end

shared.Vexora = Vexora

-- Intro: open the menu and start in the Blossom environment with falling petals.
root.Visible = true
menuScale.Scale = 0.85
tweenService:Create(menuScale, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()

World.select("Blossom", 3)

notify("Vexora Scripts", "Loaded. Press " .. misc.menuKey .. " or tap the logo to toggle the menu.", THEME.good)