import asyncio
import datetime
import json
import logging
import aiohttp
import discord
from discord import Embed, Member, Role, Colour
from discord.ext import commands
from requests_html import AsyncHTMLSession
from pathlib import Path
import logging

today = datetime.datetime.now().strftime('%d/%m/%Y')

log = logging.getLogger()

class Admin(commands.Cog):
    """
    Admin Commands
    """

    def __init__(self, bot):
        self.bot = bot
        self.gladi = discord.utils.get(self.bot.emojis, name='23')
        self.moonlord = discord.utils.get(self.bot.emojis, name='24')
        self.barbarian = discord.utils.get(self.bot.emojis, name='25')
        self.destroyer = discord.utils.get(self.bot.emojis, name='26')
        self.sniper = discord.utils.get(self.bot.emojis, name='29')
        self.artil = discord.utils.get(self.bot.emojis, name='30')
        self.tempest = discord.utils.get(self.bot.emojis, name='31')
        self.windwalker = discord.utils.get(self.bot.emojis, name='32')
        self.saleana = discord.utils.get(self.bot.emojis, name='35')
        self.elestra = discord.utils.get(self.bot.emojis, name='36')
        self.smasher = discord.utils.get(self.bot.emojis, name='37')
        self.majesty = discord.utils.get(self.bot.emojis, name='38')
        self.guardian = discord.utils.get(self.bot.emojis, name='41')
        self.crusader = discord.utils.get(self.bot.emojis, name='42')
        self.saint = discord.utils.get(self.bot.emojis, name='43')
        self.inquistor = discord.utils.get(self.bot.emojis, name='44')
        self.shooting = discord.utils.get(self.bot.emojis, name='47')
        self.gearmaster = discord.utils.get(self.bot.emojis, name='48')
        self.adept = discord.utils.get(self.bot.emojis, name='50')
        self.physician = discord.utils.get(self.bot.emojis, name='51')
        self.darksummon = discord.utils.get(self.bot.emojis, name='54')
        self.souleater = discord.utils.get(self.bot.emojis, name='55')
        self.bladedancer = discord.utils.get(self.bot.emojis, name='58')
        self.spiritdancer= discord.utils.get(self.bot.emojis, name='59')
        self.ripper = discord.utils.get(self.bot.emojis, name='63')
        self.raven = discord.utils.get(self.bot.emojis, name='64')
        self.lightfury = discord.utils.get(self.bot.emojis, name='68')
        self.abysswalker = discord.utils.get(self.bot.emojis, name='69')
        self.flurry = discord.utils.get(self.bot.emojis, name='73')
        self.breeze = discord.utils.get(self.bot.emojis, name='74')
        self.darkavenger = discord.utils.get(self.bot.emojis, name='76')
        self.defensio = discord.utils.get(self.bot.emojis, name='78')
        self.ruina = discord.utils.get(self.bot.emojis, name='79')
        self.silverhunter= discord.utils.get(self.bot.emojis, name='81')
        self.archheretic = discord.utils.get(self.bot.emojis, name='83')
        self.blackmara = discord.utils.get(self.bot.emojis, name='85')
        self.raymechanic = discord.utils.get(self.bot.emojis, name='87')
        self.oracleelder = discord.utils.get(self.bot.emojis, name='89')
        self.bleedphantom= discord.utils.get(self.bot.emojis, name='91')
        self.avalanche = discord.utils.get(self.bot.emojis, name='93')
        self.rangrid = discord.utils.get(self.bot.emojis, name='94')
        self.impactor = discord.utils.get(self.bot.emojis, name='96')
        self.lustre = discord.utils.get(self.bot.emojis, name='97')
        self.venaplaga = discord.utils.get(self.bot.emojis, name='99')

    @commands.command(pass_context=True)
    async def Account(self, ctx, accountName):
        """
        View Account Information
        """
        query = "SELECT AccountID FROM DNMembership.dbo.Accounts WHERE AccountName = ?"
        params = (accountName,)
        check = await self.bot.db.execute(query, params, single=True)

        if check is not None:
            try:
                query = """SELECT
                                c.AccountID,
                                c.AccountName,
                                c.AccountLevelCode,
                                c.cash,
                                c.email,
                                COALESCE(x.CharacterID, 0) AS CharacterCount
                            FROM
                                DNMembership.dbo.Accounts c
                            LEFT JOIN
                                (SELECT AccountID, COUNT(*) CharacterID FROM DNMembership.dbo.Characters GROUP BY AccountID) x ON c.AccountID = x.AccountID
                            WHERE
                                c.AccountName =?
                    """
                params = (accountName,)
                data = await self.bot.db.execute(query, params)
                result = json.loads(data)

                level = await self.AccountLevel(result[2])
                
                embed = Embed()
                embed.title = 'Dragon Nest'
                embed.description = f'Account ID: **[**`{result[0]}`**]**\nAccount Name: **[**`{result[1]}`**]**\n**[**`{level}`**]**\nCash: **[**`{result[3]}`**]**\nE-mail: **[**`{result[4]}`**]**\nCharacter Count: **[**`{result[5]}`**]**'
                embed.set_footer(text = today, icon_url="")
                await ctx.channel.send(embed = embed)
            except NotFound:
                pass
            except Forbidden:
                pass
        else:
            try:
                embed = Embed()
                embed.title = 'Dragon Nest'
                embed.description = 'There is no such user!'
                embed.set_footer(text = today, icon_url="")
                await ctx.channel.send(embed = embed)
            except NotFound:
                pass
            except Forbidden:
                pass

    async def AccountLevel(self, i):
        switch = {
            0: 'Player',
            24: 'Sub Moderator',
            30: 'Moderator',
            99: 'Game Master',
            100: 'Developer'
        }
        return switch.get(i, 'Account Level is unknown!')

    @commands.command(pass_context=True)
    async def Character(self, ctx, charname):
        """View Character Info e.g !Character [character name/ign]"""
        query = "SELECT CharacterName FROM DNMembership.dbo.Characters WHERE CharacterName = ?"
        params = (charname,)
        check = await self.bot.db.execute(query, params, single=True)

        if check is not None:
            try:
                query = """SELECT
                            DNWorld.dbo.Characters.CharacterID AS CharacterID,
                            DNWorld.dbo.CharacterStatus.CharacterLevel AS CharacterLevel,
                            DNWorld.dbo.CharacterStatus.JobCode AS JobCode,
                            DNWorld.dbo.CharacterStatus.Coin AS Coin,
                            DNWorld.dbo.CharacterStatus.Fatigue AS Fatigue
                        FROM 
                            DNWorld.dbo.Characters
                        INNER JOIN 
                            DNWorld.dbo.CharacterStatus ON DNWorld.dbo.Characters.CharacterID = DNWorld.dbo.CharacterStatus.CharacterID
                        WHERE 
                            DNWorld.dbo.Characters.CharacterName = ?
                """
                params = (charname,)
                data = await self.bot.db.execute(query, params)
                result = json.loads(data)

                job = await self.jobName(result[2])

                img = self.job_emoji(result[2])

                embed = Embed()
                embed.title = 'Dragon Nest'

                if img:
                    embed.description = 'Character ID: {}\nCharacter: {}\nCharacter Level: {}\nJob: {}`{}`\nCoin: {}\nFatigue: {}'.format(result[0], str(charname), result[1], img, job, result[3], result[4])
                else:
                    embed.description = 'Character ID: {}\nCharacter: {}\nCharacter Level: {}\nJob: {}\nCoin: {}\nFatigue: {}'.format(result[0], str(charname), result[1], job, result[3], result[4])
       
                embed.set_footer(text = today, icon_url="")
                await ctx.channel.send(embed = embed)
            except NotFound:
                pass
            except Forbidden:
                pass
        else:
            try:
                embed = Embed()
                embed.title = 'Dragon Nest'
                embed.description = 'Character Doesnt Exists!'
                embed.set_footer(text = today, icon_url="")
                await ctx.channel.send(embed = embed)
            except NotFound:
                pass
            except Forbidden:
                pass

    def job_emoji(self, job_id):

        switch = {
            23: self.gladi,
            24: self.moonlord,
            25: self.barbarian,
            26: self.destroyer,
            29: self.sniper,
            30: self.artil,
            31: self.tempest,
            32: self.windwalker,
            35: self.saleana,
            36: self.elestra,
            37: self.smasher,
            38: self.majesty,
            41: self.guardian,
            42: self.crusader,
            43: self.saint,
            44: self.inquistor,
            47: self.shooting,
            48: self.gearmaster,
            50: self.adept,
            51: self.physician,
            54: self.darksummon,
            55: self.souleater,
            58: self.bladedancer,
            59: self.spiritdancer,
            63: self.ripper,
            64: self.raven,
            68: self.lightfury,
            69: self.abysswalker,
            73: self.flurry,
            74: self.breeze,
            76: self.darkavenger,
            78: self.defensio,
            79: self.ruina,
            81: self.silverhunter,
            83: self.archheretic,
            85: self.blackmara,
            87: self.raymechanic,
            89: self.oracleelder,
            91: self.bleedphantom,
            93: self.avalanche,
            94: self.rangrid,
            96: self.impactor,
            97: self.lustre,
            99: self.venaplaga,
        }

        return switch.get(job_id, False)

    async def jobName(self, job_id):
        switch = {
            1: 'Warrior',
            2: 'Archer',
            3: 'Sorceress',
            4: 'Cleric',
            5: 'Academic',
            6: 'kali',
            7: 'Assassin',
            8: 'Lancea',
            9: 'Machina',
            11: 'Sword Master',
            12: 'Mercenary',
            14: 'Bow Master',
            15: 'Acrobat',
            17: 'Elemental Lord',
            18: 'Force User',
            19: 'Warlock',
            20: 'Paladin',
            21: 'Monk',
            22: 'Priest',
            23: 'Gladiator',
            24: 'Moon Lord',
            25: 'Barbarian',
            26: 'Destroyer',
            29: 'Sniper',
            30: 'Artillery',
            31: 'Tempest',
            32: 'Wind Walker',
            35: 'Saleana',
            36: 'Elestra',
            37: 'Smasher',
            38: 'Majesty',
            41: 'Guardian',
            42: 'Crusador',
            43: 'Saint',
            44: 'Inquisitor',
            45: 'Exorcist',
            46: 'Engineer',
            47: 'Shooting Star',
            48: 'Gear Master',
            49: 'Alchemist',
            50: 'Adept',
            51: 'Physician',
            54: 'Screamer',
            55: 'Dark Summoner',
            56: 'Soul Eater',
            57: 'Dancer',
            58: 'Blade Dancer',
            59: 'Spirit Dancer',
            62: 'Chaser',
            63: 'Ripper',
            64: 'Raven',
            67: 'Bringer',
            68: 'Light Fury',
            69: 'Abyss Walker',
            72: 'Piercer',
            73: 'Flurry',
            74: 'Sting Breezer',
            75: 'Avenger',
            76: 'Dark Avenger',
            77: 'Patrona',
            78: 'Defensio',
            79: 'Ruina',
            80: 'Hunter',
            81: 'Silver Hunter',
            82: 'Heretic',
            83: 'Arch Heretic',
            84: 'Mara',
            85: 'Black Mara',
            86: 'Mechanic',
            87: 'Ray Mechanic',
            88: 'Oracle',
            89: 'Oracle Elder',
            90: 'Phantom',
            91: 'Bleed Phantom',
            92: 'Knightess',
            93: 'Avalanche',
            94: 'Randgrid',
            95: 'Launcher',
            96: 'Impactor',
            97: 'Buster',
            98: 'Plaga',
            99: 'Vena Plaga',
        }

        return switch.get(job_id, "Invalid Job ID")

def setup(bot):
    bot.add_cog(Admin(bot))