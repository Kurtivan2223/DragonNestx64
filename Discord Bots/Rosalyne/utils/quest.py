import logging
import discord
import datetime
from datetime import timedelta
from discord.ext import commands, tasks
from discord.utils import sane_wait_for
import pyodbc

log = logging.getLogger()

class Mission(commands.Cog):
    """
    Mission Logging
    """

    def __init__(self, bot):
        self.bot = bot
        self.init_quest.start()

    @tasks.loop(seconds=0.95)
    async def init_quest(self):
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

        channel = self.bot.get_channel(1009497401750474862)
        datetimeFormat = '%Y-%m-%d %H:%M:%S'

        connection = pyodbc.connect('DRIVER={SQL Server};Server=127.0.0.1,1433;DATABASE=DNMembership;UID=DragonNest;PWD=uZBfDg7e6LZxZfM')
        cursor = connection.cursor()
        getdate2 = datetime.datetime.today().strftime('%Y-%m-%d %H:%M:%S')

        cursor.execute("""SELECT
                            DNWorld.dbo.CompleteQuests.CharacterID, 
                            DNWorld.dbo.CompleteQuests.QuestID, 
                            DNWorld.dbo.Quests.RegisterDate,
                            DNWorld.dbo.CompleteQuests.CompleteDate,
                            DNWorld.dbo.Characters.CharacterName,
                            DNWorld.dbo.CharacterStatus.JobCode
                        FROM
                            DNWorld.dbo.CompleteQuests
                        LEFT JOIN
                            DNWorld.dbo.Quests
                        ON
                            DNWorld.dbo.CompleteQuests.CharacterID = DNWorld.dbo.Quests.CharacterID
                        LEFT JOIN
                            DNWorld.dbo.Characters
                        ON
                            DNWorld.dbo.CompleteQuests.CharacterID = DNWorld.dbo.Characters.CharacterID                       
                        LEFT JOIN
                            DNWorld.dbo.CharacterStatus
                        ON
                            DNWorld.dbo.CompleteQuests.CharacterID = DNWorld.dbo.CharacterStatus.CharacterID""")

        character_id = quest_id = register_date = complete_date = character_name = job_code = ""
        for row in cursor:
            character_id, quest_id, register_date, complete_date, character_name, job_code = row
        
        if complete_date == getdate2:
            diff = datetime.datetime.strptime(complete_date, datetimeFormat)\
            - datetime.datetime.strptime(register_date, datetimeFormat)

            seconds = (int(diff.total_seconds()))
            hours = seconds // 3600
            minutes = (seconds % 3600) // 60
            seconds = seconds % 60

            if hours == 0:
                log.info('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(job_code, character_name, quest_id,minutes, seconds))
                if job_code == 23:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(gladi), character_name, quest_id,minutes, seconds))

                elif job_code == 24:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(moonlord), character_name, quest_id,minutes, seconds))

                elif job_code == 25:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(barbarian), character_name, quest_id,minutes, seconds))

                elif job_code == 26:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(destroyer), character_name, quest_id,minutes, seconds))

                elif job_code == 29:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(sniper), character_name, quest_id,minutes, seconds))

                elif job_code == 30:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(artil), character_name, quest_id,minutes, seconds))

                elif job_code == 31:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(tempest), character_name, quest_id,minutes, seconds))

                elif job_code == 32:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(windwalker), character_name, quest_id,minutes, seconds))

                elif job_code == 35:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(saleana), character_name, quest_id,minutes, seconds))

                elif job_code == 36:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(elestra), character_name, quest_id,minutes, seconds))

                elif job_code == 37:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(smasher), character_name, quest_id,minutes, seconds))

                elif job_code == 38:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(majesty), character_name, quest_id,minutes, seconds))

                elif job_code == 41:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(guardian), character_name, quest_id,minutes, seconds))

                elif job_code == 42:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(crusader), character_name, quest_id,minutes, seconds))

                elif job_code == 43:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(saint), character_name, quest_id,minutes, seconds))

                elif job_code == 44:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(inquistor), character_name, quest_id,minutes, seconds))

                elif job_code == 47:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(shooting), character_name, quest_id,minutes, seconds))

                elif job_code == 48:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(gearmaster), character_name, quest_id,minutes, seconds))

                elif job_code == 50:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(adept), character_name, quest_id,minutes, seconds))

                elif job_code == 51:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(physician), character_name, quest_id,minutes, seconds))

                elif job_code == 55:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(darksummon), character_name, quest_id,minutes, seconds))

                elif job_code == 56:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(souleater), character_name, quest_id,minutes, seconds))

                elif job_code == 58:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(bladedancer), character_name, quest_id,minutes, seconds))

                elif job_code == 59:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(spiritdancer), character_name, quest_id,minutes, seconds))

                elif job_code == 63:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(ripper), character_name, quest_id,minutes, seconds))

                elif job_code == 64:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(raven), character_name, quest_id,minutes, seconds))

                elif job_code == 68:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(lightfury), character_name, quest_id,minutes, seconds))

                elif job_code == 69:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(abysswalker), character_name, quest_id,minutes, seconds))

                elif job_code == 73:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(flurry), character_name, quest_id,minutes, seconds))

                elif job_code == 74:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(breeze), character_name, quest_id,minutes, seconds))

                elif job_code == 76:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(darkavenger), character_name, quest_id,minutes, seconds))

                elif job_code == 78:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(defensio), character_name, quest_id,minutes, seconds))

                elif job_code == 79:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(ruina), character_name, quest_id,minutes, seconds))

                elif job_code == 81:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(silverhunter), character_name, quest_id,minutes, seconds))

                elif job_code == 83:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(archheretic), character_name, quest_id,minutes, seconds))

                elif job_code == 85:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(blackmara), character_name, quest_id,minutes, seconds))

                elif job_code == 87:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(raymechanic), character_name, quest_id,minutes, seconds))

                elif job_code == 89:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(oracleelder), character_name, quest_id,minutes, seconds))

                elif job_code == 91:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(bleedphantom), character_name, quest_id,minutes, seconds))

                elif job_code == 93:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(avalanche), character_name, quest_id,minutes, seconds))

                elif job_code == 94:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(rangrid), character_name, quest_id,minutes, seconds))

                elif job_code == 96:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(impactor), character_name, quest_id,minutes, seconds))

                elif job_code == 97:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(lustre), character_name, quest_id,minutes, seconds))

                elif job_code == 99:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} minutes, {} seconds`**]**'.format(str(venaplaga), character_name, quest_id,minutes, seconds))

            elif hours > 0:
                log.info('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(job_code, character_name, quest_id, hours, minutes, seconds)) 
                if job_code == 23:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(gladi), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 24:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(moonlord), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 25:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(barbarian), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 26:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(destroyer), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 29:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(sniper), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 30:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(artil), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 31:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(tempest), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 32:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(windwalker), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 35:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(saleana), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 36:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(elestra), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 37:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(smasher), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 38:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(majesty), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 41:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(guardian), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 42:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(crusader), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 43:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(saint), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 44:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(inquistor), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 47:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(shooting), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 48:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(gearmaster), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 50:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(adept), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 51:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(physician), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 55:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(darksummon), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 56:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(souleater), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 58:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(bladedancer), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 59:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(spiritdancer), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 63:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(ripper), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 64:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(raven), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 68:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(lightfury), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 69:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(abysswalker), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 73:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(flurry), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 74:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(breeze), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 76:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(darkavenger), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 78:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(defensio), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 79:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(ruina), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 81:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(silverhunter), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 83:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(archheretic), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 85:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(blackmara), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 87:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(raymechanic), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 89:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(oracleelder), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 91:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(bleedphantom), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 93:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(avalanche), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 94:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(rangrid), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 96:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(impactor), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 97:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(lustre), character_name, quest_id, hours, minutes, seconds)) 

                elif job_code == 99:
                    await channel.send('{} **[**`{}`**]** has cleared Quest ID **[{}]** instance with a time of **[**`{} hours ,{} minutes, {} seconds`**]**'.format(str(venaplaga), character_name, quest_id, hours, minutes, seconds))

def setup(bot):
    bot.add_cog(Mission(bot))