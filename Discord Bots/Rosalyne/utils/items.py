import logging
import discord
import datetime
from datetime import timedelta
from discord.ext import commands, tasks
from discord.utils import sane_wait_for
import pyodbc

log = logging.getLogger()

class Items(commands.Cog):
    """
    Item Logging
    """

    def __init__(self, bot):
        self.bot = bot
        self.init_item.start()

    @tasks.loop(seconds=0.95)
    async def init_item(self):
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

        channel = self.bot.get_channel(1009736897330937876)
        datetimeFormat = '%Y-%m-%d %H:%M:%S'

        connection = pyodbc.connect('DRIVER={SQL Server};Server=127.0.0.1,1433;DATABASE=DNMembership;UID=DragonNest;PWD=uZBfDg7e6LZxZfM')
        cursor = connection.cursor()
        getdate2 = datetime.datetime.today().strftime('%Y-%m-%d %H:%M:%S')

        cursor.execute("""SELECT
                            DNWorld.dbo.ItemTable._ItemID,
                            DNWorld.dbo.ItemTable._ItemName,
                            DNWorld.dbo.MaterializedItems.ItemMaterializeDate,
                            DNWorld.dbo.MaterializedItems.OwnerCharacterID,
                            DNWorld.dbo.Characters.CharacterName,
                            DNWorld.dbo.CharacterStatus.JobCode,
                            DNWorld.dbo.MaterializedItems.ItemCount
                        FROM
                            DNWorld.dbo.ItemTable
                        INNER JOIN
                            DNWorld.dbo.MaterializedItems
                        ON
                            DNWorld.dbo.ItemTable._ItemID = DNWorld.dbo.MaterializedItems.ItemID
                        INNER JOIN
                            DNWorld.dbo.Characters
                        ON
                            DNWorld.dbo.MaterializedItems.OwnerCharacterID = DNWorld.dbo.Characters.CharacterID
                        INNER JOIN
                            DNWorld.dbo.CharacterStatus
                        ON
                            DNWorld.dbo.MaterializedItems.OwnerCharacterID = DNWorld.dbo.CharacterStatus.CharacterID""")

        item_id = item_name = materialized_date = character_id = character_name = job_code = item_count = ""
        for row in cursor:
            item_id, item_name, materialized_date, character_id, character_name, job_code, item_count = row          

        if materialized_date == getdate2:
            log.info(('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(job_code, character_name, item_count, item_name)))
            if job_code == 23:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(gladi), character_name, item_count, item_name))

            elif job_code == 24:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(moonlord), character_name,  item_count, item_name))

            elif job_code == 25:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(barbarian), character_name,  item_count, item_name))

            elif job_code == 26:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(destroyer), character_name,  item_count, item_name))

            elif job_code == 29:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(sniper), character_name,  item_count, item_name))

            elif job_code == 30:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(artil), character_name,  item_count, item_name))

            elif job_code == 31:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(tempest), character_name,  item_count, item_name))

            elif job_code == 32:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(windwalker), character_name,  item_count, item_name))

            elif job_code == 35:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(saleana), character_name,  item_count, item_name))

            elif job_code == 36:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(elestra), character_name,  item_count, item_name))

            elif job_code == 37:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(smasher), character_name,  item_count, item_name))

            elif job_code == 38:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(majesty), character_name,  item_count, item_name))

            elif job_code == 41:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(guardian), character_name,  item_count, item_name))

            elif job_code == 42:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(crusader), character_name,  item_count, item_name))

            elif job_code == 43:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(saint), character_name,  item_count, item_name))

            elif job_code == 44:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(inquistor), character_name,  item_count, item_name))

            elif job_code == 47:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(shooting), character_name,  item_count, item_name))

            elif job_code == 48:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(gearmaster), character_name,  item_count, item_name))

            elif job_code == 50:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(adept), character_name,  item_count, item_name))

            elif job_code == 51:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(physician), character_name,  item_count, item_name))

            elif job_code == 55:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(darksummon), character_name,  item_count, item_name))

            elif job_code == 56:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(souleater), character_name,  item_count, item_name))

            elif job_code == 58:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(bladedancer), character_name,  item_count, item_name))

            elif job_code == 59:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(spiritdancer), character_name,  item_count, item_name))

            elif job_code == 63:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(ripper), character_name,  item_count, item_name))

            elif job_code == 64:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(raven), character_name,  item_count, item_name))

            elif job_code == 68:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(lightfury), character_name,  item_count, item_name))

            elif job_code == 69:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(abysswalker), character_name,  item_count, item_name))

            elif job_code == 73:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(flurry), character_name,  item_count, item_name))

            elif job_code == 74:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(breeze), character_name,  item_count, item_name))

            elif job_code == 76:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(darkavenger), character_name,  item_count, item_name))

            elif job_code == 78:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(defensio), character_name,  item_count, item_name))

            elif job_code == 79:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(ruina), character_name,  item_count, item_name))

            elif job_code == 81:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(silverhunter), character_name,  item_count, item_name))

            elif job_code == 83:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(archheretic), character_name,  item_count, item_name))

            elif job_code == 85:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(blackmara), character_name,  item_count, item_name))

            elif job_code == 87:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(raymechanic), character_name,  item_count, item_name))

            elif job_code == 89:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(oracleelder), character_name,  item_count, item_name))

            elif job_code == 91:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(bleedphantom), character_name,  item_count, item_name))

            elif job_code == 93:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(avalanche), character_name,  item_count, item_name))

            elif job_code == 94:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(rangrid), character_name,  item_count, item_name))

            elif job_code == 96:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(impactor), character_name,  item_count, item_name))

            elif job_code == 97:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(lustre), character_name,  item_count, item_name))

            elif job_code == 99:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(str(venaplaga), character_name,  item_count, item_name))
            else:
                await channel.send('{} **[**`{}`**]** has Obtained **[**`{} pieces`**]** of **[**`{}`**]**'.format(job_code, character_name,  item_count, item_name))
def setup(bot):
    bot.add_cog(Items(bot))