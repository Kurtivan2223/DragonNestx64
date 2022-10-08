import logging
import discord
import datetime
from datetime import timedelta
from discord.ext import commands, tasks
from discord.utils import sane_wait_for
import pyodbc

log = logging.getLogger()

class Nest(commands.Cog):
    """
    Nest Events
    """

    def __init__(self, bot):
        self.bot = bot
        self.init_nest.start()

    @tasks.loop(seconds=0.95)
    async def init_nest(self):
        gladi       = discord.utils.get(self.bot.emojis, name='23')
        moonlord    = discord.utils.get(self.bot.emojis, name='24')
        barbarian   = discord.utils.get(self.bot.emojis, name='25')
        destroyer   = discord.utils.get(self.bot.emojis, name='26')
        sniper      = discord.utils.get(self.bot.emojis, name='29')
        artil       = discord.utils.get(self.bot.emojis, name='30')
        tempest     = discord.utils.get(self.bot.emojis, name='31')
        windwalker  = discord.utils.get(self.bot.emojis, name='32')
        saleana     = discord.utils.get(self.bot.emojis, name='35')
        elestra     = discord.utils.get(self.bot.emojis, name='36')
        smasher     = discord.utils.get(self.bot.emojis, name='37')
        majesty     = discord.utils.get(self.bot.emojis, name='38')
        guardian    = discord.utils.get(self.bot.emojis, name='41')
        crusader    = discord.utils.get(self.bot.emojis, name='42')
        saint       = discord.utils.get(self.bot.emojis, name='43')
        inquistor   = discord.utils.get(self.bot.emojis, name='44')
        shooting    = discord.utils.get(self.bot.emojis, name='47')
        gearmaster  = discord.utils.get(self.bot.emojis, name='48')
        adept       = discord.utils.get(self.bot.emojis, name='50')
        physician   = discord.utils.get(self.bot.emojis, name='51')
        darksummon  = discord.utils.get(self.bot.emojis, name='54')
        souleater   = discord.utils.get(self.bot.emojis, name='55')
        bladedancer = discord.utils.get(self.bot.emojis, name='58')
        spiritdancer= discord.utils.get(self.bot.emojis, name='59')
        ripper      = discord.utils.get(self.bot.emojis, name='63')
        raven       = discord.utils.get(self.bot.emojis, name='64')
        lightfury   = discord.utils.get(self.bot.emojis, name='68')
        abysswalker = discord.utils.get(self.bot.emojis, name='69')
        flurry      = discord.utils.get(self.bot.emojis, name='73')
        breeze      = discord.utils.get(self.bot.emojis, name='74')
        darkavenger = discord.utils.get(self.bot.emojis, name='76')
        defensio    = discord.utils.get(self.bot.emojis, name='78')
        ruina       = discord.utils.get(self.bot.emojis, name='79')
        silverhunter= discord.utils.get(self.bot.emojis, name='81')
        archheretic = discord.utils.get(self.bot.emojis, name='83')
        blackmara   = discord.utils.get(self.bot.emojis, name='85')
        raymechanic = discord.utils.get(self.bot.emojis, name='87')
        oracleelder = discord.utils.get(self.bot.emojis, name='89')
        bleedphantom= discord.utils.get(self.bot.emojis, name='91')
        avalanche   = discord.utils.get(self.bot.emojis, name='93')
        rangrid     = discord.utils.get(self.bot.emojis, name='94')
        impactor    = discord.utils.get(self.bot.emojis, name='96')
        lustre      = discord.utils.get(self.bot.emojis, name='97')
        venaplaga   = discord.utils.get(self.bot.emojis, name='99')

        channel = self.bot.get_channel(907603444540538881)
        datetimeFormat = '%Y-%m-%d %H:%M:%S'

        connection = pyodbc.connect('DRIVER={SQL Server};Server=127.0.0.1,1433;DATABASE=DNMembership;UID=DragonNest;PWD=uZBfDg7e6LZxZfM')
        cursor = connection.cursor()
        getdate2 = datetime.datetime.today().strftime('%Y-%m-%d %H:%M:%S')
        
        cursor.execute("""SELECT
                            DNWorld.dbo.StageEndLogs0.CharacterID, 
                            DNWorld.dbo.StageEndLogs0.JobCode, 
                            DNWorld.dbo.StageEndLogs0.ClearFlag,
                            DNWorld.dbo.StageEndLogs0.StageEndDate,
                            DNWorld.dbo.StageStartIDs.StageStartDate,
                            DNWorld.dbo.StageStartIDs.MapID,
                            DNWorld.dbo.MapTable._MapName,
                            DNWorld.dbo.Characters.CharacterName
                        FROM
                            DNWorld.dbo.StageEndLogs0
                        LEFT JOIN
                            DNWorld.dbo.StageStartIDs
                        ON
                            DNWorld.dbo.StageEndLogs0.StageStartID = DNWorld.dbo.StageStartIDs.StageStartID
                                                    
                        LEFT JOIN
                            DNWorld.dbo.MapTable
                        ON
                            DNWorld.dbo.StageStartIDs.MapID = DNWorld.dbo.MapTable._MapID
                        LEFT JOIN
                            DNWorld.dbo.Characters
                        ON
                            DNWorld.dbo.StageEndLogs0.CharacterID = DNWorld.dbo.Characters.CharacterID
                        WHERE
                            DNWorld.dbo.StageEndLogs0.ClearFlag = 1 """)

        character_id = job_code = clear_flag = stage_end = stage_start = map_id = location_player = character_name = ""
        for row in cursor:
            character_id, job_code, clear_flag, stage_end, stage_start, map_id, location_player, character_name = row


            if stage_end == getdate2:
                diff = datetime.datetime.strptime(stage_end, datetimeFormat)\
                - datetime.datetime.strptime(stage_start, datetimeFormat)

                seconds = (int(diff.total_seconds()))
                hours = seconds // 3600
                minutes = (seconds % 3600) // 60
                seconds = seconds % 60

     
                if hours == 0:
                    log.info('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(job_code,character_name,location_player,minutes, seconds))
                    if job_code == 23:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(gladi),character_name,location_player,minutes, seconds))

                    elif job_code == 24:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(moonlord),character_name,location_player,minutes, seconds))

                    elif job_code == 25:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(barbarian),character_name,location_player,minutes, seconds))

                    elif job_code == 26:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(destroyer),character_name,location_player,minutes, seconds))

                    elif job_code == 29:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(sniper),character_name,location_player,minutes, seconds))

                    elif job_code == 30:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(artil),character_name,location_player,minutes, seconds))

                    elif job_code == 31:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(tempest),character_name,location_player,minutes, seconds))

                    elif job_code == 32:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(windwalker),character_name,location_player,minutes, seconds))

                    elif job_code == 35:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(saleana),character_name,location_player,minutes, seconds))

                    elif job_code == 36:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(elestra),character_name,location_player,minutes, seconds))

                    elif job_code == 37:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(smasher),character_name,location_player,minutes, seconds))

                    elif job_code == 38:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(majesty),character_name,location_player,minutes, seconds))

                    elif job_code == 41:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(guardian),character_name,location_player,minutes, seconds))

                    elif job_code == 42:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(crusader),character_name,location_player,minutes, seconds))

                    elif job_code == 43:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(saint),character_name,location_player,minutes, seconds))

                    elif job_code == 44:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(inquistor),character_name,location_player,minutes, seconds))

                    elif job_code == 47:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(shooting),character_name,location_player,minutes, seconds))

                    elif job_code == 48:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(gearmaster),character_name,location_player,minutes, seconds))

                    elif job_code == 50:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(adept),character_name,location_player,minutes, seconds))

                    elif job_code == 51:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(physician),character_name,location_player,minutes, seconds))

                    elif job_code == 55:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(darksummon),character_name,location_player,minutes, seconds))

                    elif job_code == 56:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(souleater),character_name,location_player,minutes, seconds))

                    elif job_code == 58:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(bladedancer),character_name,location_player,minutes, seconds))

                    elif job_code == 59:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(spiritdancer),character_name,location_player,minutes, seconds))

                    elif job_code == 63:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(ripper),character_name,location_player,minutes, seconds))

                    elif job_code == 64:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(raven),character_name,location_player,minutes, seconds))

                    elif job_code == 68:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(lightfury),character_name,location_player,minutes, seconds))

                    elif job_code == 69:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(abysswalker),character_name,location_player,minutes, seconds))

                    elif job_code == 73:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(flurry),character_name,location_player,minutes, seconds))

                    elif job_code == 74:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(breeze),character_name,location_player,minutes, seconds))

                    elif job_code == 76:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(darkavenger),character_name,location_player,minutes, seconds))

                    elif job_code == 78:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(defensio),character_name,location_player,minutes, seconds))

                    elif job_code == 79:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(ruina),character_name,location_player,minutes, seconds))

                    elif job_code == 81:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(silverhunter),character_name,location_player,minutes, seconds))

                    elif job_code == 83:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(archheretic),character_name,location_player,minutes, seconds))

                    elif job_code == 85:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(blackmara),character_name,location_player,minutes, seconds))

                    elif job_code == 87:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(raymechanic),character_name,location_player,minutes, seconds))

                    elif job_code == 89:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(oracleelder),character_name,location_player,minutes, seconds))

                    elif job_code == 91:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(bleedphantom),character_name,location_player,minutes, seconds))

                    elif job_code == 93:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(avalanche),character_name,location_player,minutes, seconds))

                    elif job_code == 94:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(rangrid),character_name,location_player,minutes, seconds))

                    elif job_code == 96:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(impactor),character_name,location_player,minutes, seconds))

                    elif job_code == 97:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(lustre),character_name,location_player,minutes, seconds))

                    elif job_code == 99:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(venaplaga),character_name,location_player,minutes, seconds))


                elif hours > 0:
                    log.info('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(job_code,character_name,location_player,hours,minutes, seconds)) 
                    if job_code == 23:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(gladi),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 24:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(moonlord),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 25:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(barbarian),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 26:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(destroyer),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 29:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(sniper),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 30:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(artil),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 31:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(tempest),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 32:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(windwalker),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 35:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(saleana),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 36:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(elestra),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 37:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(smasher),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 38:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(majesty),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 41:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(guardian),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 42:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(crusader),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 43:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(saint),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 44:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(inquistor),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 47:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(shooting),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 48:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(gearmaster),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 50:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(adept),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 51:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(physician),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 55:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(darksummon),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 56:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(souleater),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 58:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(bladedancer),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 59:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(spiritdancer),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 63:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(ripper),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 64:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(raven),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 68:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(lightfury),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 69:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(abysswalker),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 73:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(flurry),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 74:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(breeze),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 76:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(darkavenger),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 78:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(defensio),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 79:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(ruina),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 81:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(silverhunter),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 83:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(archheretic),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 85:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(blackmara),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 87:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(raymechanic),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 89:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(oracleelder),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 91:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(bleedphantom),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 93:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(avalanche),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 94:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(rangrid),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 96:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(impactor),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 97:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(lustre),character_name,location_player,hours,minutes, seconds)) 

                    elif job_code == 99:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(venaplaga),character_name,location_player,hours,minutes, seconds)) 


        cursor.execute("""SELECT
                            DNWorld.dbo.StageEndLogs1.CharacterID, 
                            DNWorld.dbo.StageEndLogs1.JobCode, 
                            DNWorld.dbo.StageEndLogs1.ClearFlag,
                            DNWorld.dbo.StageEndLogs1.StageEndDate,
                            DNWorld.dbo.StageStartIDs.StageStartDate,
                            DNWorld.dbo.StageStartIDs.MapID,
                            DNWorld.dbo.MapTable._MapName,
                            DNWorld.dbo.Characters.CharacterName
                        FROM
                            DNWorld.dbo.StageEndLogs1
                        LEFT JOIN
                            DNWorld.dbo.StageStartIDs
                        ON
                            DNWorld.dbo.StageEndLogs1.StageStartID = DNWorld.dbo.StageStartIDs.StageStartID
                                                    
                        LEFT JOIN
                            DNWorld.dbo.MapTable
                        ON
                            DNWorld.dbo.StageStartIDs.MapID = DNWorld.dbo.MapTable._MapID
                        LEFT JOIN
                            DNWorld.dbo.Characters
                        ON
                            DNWorld.dbo.StageEndLogs1.CharacterID = DNWorld.dbo.Characters.CharacterID  
                        WHERE
                            DNWorld.dbo.StageEndLogs1.ClearFlag = 1 """)

        character_id1 = job_code1 = clear_flag1 = stage_end1 = stage_start1 = map_id1 = location_player1 = character_name1 = ""
        for row in cursor:
            character_id1, job_code1, clear_flag1, stage_end1, stage_start1,map_id1, location_player1, character_name1 = row


            if stage_end1 == getdate2:
                diff = datetime.datetime.strptime(stage_end1, datetimeFormat)\
                - datetime.datetime.strptime(stage_start1, datetimeFormat)

                seconds = (int(diff.total_seconds()))
                hours = seconds // 3600
                minutes = (seconds % 3600) // 60
                seconds = seconds % 60

                if hours == 0:
                    log.info('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(job_code1,character_name1,location_player1,minutes, seconds))
                    if job_code1 == 23:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(gladi),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 24:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(moonlord),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 25:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(barbarian),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 26:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(destroyer),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 29:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(sniper),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 30:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(artil),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 31:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(tempest),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 32:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(windwalker),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 35:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(saleana),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 36:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(elestra),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 37:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(smasher),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 38:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(majesty),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 41:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(guardian),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 42:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(crusader),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 43:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(saint),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 44:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(inquistor),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 47:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(shooting),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 48:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(gearmaster),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 50:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(adept),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 51:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(physician),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 55:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(darksummon),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 56:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(souleater),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 58:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(bladedancer),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 59:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(spiritdancer),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 63:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(ripper),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 64:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(raven),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 68:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(lightfury),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 69:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(abysswalker),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 73:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(flurry),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 74:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(breeze),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 76:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(darkavenger),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 78:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(defensio),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 79:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(ruina),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 81:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(silverhunter),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 83:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(archheretic),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 85:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(blackmara),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 87:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(raymechanic),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 89:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(oracleelder),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 91:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(bleedphantom),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 93:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(avalanche),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 94:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(rangrid),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 96:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(impactor),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 97:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(lustre),character_name1,location_player1,minutes, seconds))

                    elif job_code1 == 99:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(venaplaga),character_name1,location_player1,minutes, seconds))


                elif hours > 0:
                    log.info('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(job_code1,character_name1,location_player1,hours,minutes, seconds)) 
                    if job_code1 == 23:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(gladi),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 24:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(moonlord),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 25:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(barbarian),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 26:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(destroyer),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 29:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(sniper),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 30:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(artil),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 31:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(tempest),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 32:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(windwalker),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 35:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(saleana),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 36:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(elestra),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 37:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(smasher),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 38:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(majesty),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 41:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(guardian),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 42:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(crusader),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 43:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(saint),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 44:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(inquistor),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 47:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(shooting),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 48:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(gearmaster),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 50:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(adept),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 51:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(physician),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 55:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(darksummon),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 56:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(souleater),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 58:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(bladedancer),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 59:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(spiritdancer),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 63:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(ripper),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 64:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(raven),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 68:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(lightfury),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 69:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(abysswalker),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 73:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(flurry),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 74:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(breeze),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 76:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(darkavenger),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 78:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(defensio),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 79:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(ruina),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 81:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(silverhunter),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 83:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(archheretic),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 85:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(blackmara),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 87:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(raymechanic),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 89:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(oracleelder),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 91:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(bleedphantom),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 93:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(avalanche),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 94:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(rangrid),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 96:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(impactor),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 97:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(lustre),character_name1,location_player1,hours,minutes, seconds)) 

                    elif job_code1 == 99:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(venaplaga),character_name1,location_player1,hours,minutes, seconds)) 


        cursor.execute("""SELECT
                            DNWorld.dbo.StageEndLogs2.CharacterID, 
                            DNWorld.dbo.StageEndLogs2.JobCode, 
                            DNWorld.dbo.StageEndLogs2.ClearFlag,
                            DNWorld.dbo.StageEndLogs2.StageEndDate,
                            DNWorld.dbo.StageStartIDs.StageStartDate,
                            DNWorld.dbo.StageStartIDs.MapID,
                            DNWorld.dbo.MapTable._MapName,
                            DNWorld.dbo.Characters.CharacterName
                        FROM
                            DNWorld.dbo.StageEndLogs2
                        LEFT JOIN
                            DNWorld.dbo.StageStartIDs
                        ON
                            DNWorld.dbo.StageEndLogs2.StageStartID = DNWorld.dbo.StageStartIDs.StageStartID						
                        LEFT JOIN
                            DNWorld.dbo.MapTable
                        ON
                            DNWorld.dbo.StageStartIDs.MapID = DNWorld.dbo.MapTable._MapID
                        LEFT JOIN
                            DNWorld.dbo.Characters
                        ON
                            DNWorld.dbo.StageEndLogs2.CharacterID = DNWorld.dbo.Characters.CharacterID
                        WHERE
                            DNWorld.dbo.StageEndLogs2.ClearFlag = 1 """)

        character_id2 = job_code2 = clear_flag2 = stage_end2 = stage_start2 = map_id2 = location_player2 = character_name2 = ""
        for row in cursor:
            character_id2, job_code2, clear_flag2, stage_end2, stage_start2,map_id2, location_player2, character_name2 = row


            if stage_end2 == getdate2:
                diff = datetime.datetime.strptime(stage_end2, datetimeFormat)\
                - datetime.datetime.strptime(stage_start2, datetimeFormat)

                seconds = (int(diff.total_seconds()))
                hours = seconds // 3600
                minutes = (seconds % 3600) // 60
                seconds = seconds % 60

                if hours == 0:
                    log.info('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(job_code2,character_name2,location_player2,minutes, seconds))
                    if job_code2 == 23:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(gladi),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 24:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(moonlord),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 25:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(barbarian),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 26:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(destroyer),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 29:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(sniper),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 30:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(artil),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 31:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(tempest),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 32:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(windwalker),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 35:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(saleana),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 36:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(elestra),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 37:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(smasher),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 38:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(majesty),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 41:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(guardian),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 42:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(crusader),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 43:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(saint),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 44:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(inquistor),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 47:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(shooting),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 48:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(gearmaster),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 50:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(adept),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 51:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(physician),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 55:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(darksummon),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 56:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(souleater),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 58:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(bladedancer),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 59:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(spiritdancer),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 63:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(ripper),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 64:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(raven),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 68:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(lightfury),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 69:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(abysswalker),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 73:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(flurry),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 74:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(breeze),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 76:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(darkavenger),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 78:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(defensio),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 79:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(ruina),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 81:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(silverhunter),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 83:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(archheretic),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 85:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(blackmara),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 87:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(raymechanic),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 89:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(oracleelder),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 91:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(bleedphantom),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 93:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(avalanche),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 94:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(rangrid),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 96:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(impactor),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 97:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(lustre),character_name2,location_player2,minutes, seconds))

                    elif job_code2 == 99:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(venaplaga),character_name2,location_player2,minutes, seconds))


                elif hours > 0:
                    log.info('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(job_code2,character_name2,location_player2,hours,minutes, seconds)) 
                    if job_code2 == 23:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(gladi),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 24:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(moonlord),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 25:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(barbarian),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 26:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(destroyer),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 29:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(sniper),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 30:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(artil),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 31:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(tempest),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 32:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(windwalker),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 35:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(saleana),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 36:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(elestra),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 37:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(smasher),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 38:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(majesty),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 41:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(guardian),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 42:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(crusader),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 43:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(saint),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 44:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(inquistor),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 47:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(shooting),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 48:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(gearmaster),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 50:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(adept),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 51:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(physician),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 55:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(darksummon),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 56:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(souleater),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 58:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(bladedancer),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 59:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(spiritdancer),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 63:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(ripper),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 64:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(raven),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 68:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(lightfury),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 69:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(abysswalker),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 73:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(flurry),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 74:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(breeze),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 76:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(darkavenger),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 78:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(defensio),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 79:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(ruina),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 81:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(silverhunter),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 83:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(archheretic),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 85:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(blackmara),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 87:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(raymechanic),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 89:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(oracleelder),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 91:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(bleedphantom),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 93:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(avalanche),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 94:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(rangrid),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 96:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(impactor),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 97:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(lustre),character_name2,location_player2,hours,minutes, seconds)) 

                    elif job_code2 == 99:
                        await channel.send('{} **[**`{}`**]** has cleared the **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(venaplaga),character_name2,location_player2,hours,minutes, seconds)) 

def setup(bot):
    bot.add_cog(Nest(bot))