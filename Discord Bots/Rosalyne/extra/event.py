import os
import re
import logging
import discord
import json
import urllib
import datetime
import asyncio
from discord import Embed, Colour, NotFound, Forbidden
from discord.ext import commands, tasks
from pathlib import Path
import psutil

log = logging.getLogger()
today = datetime.datetime.now().strftime('%d/%m/%Y')

class Event(commands.Cog):
    """
    Bot Events
    """

    def __init__(self, bot):
        self.bot = bot
        self.guild = self.bot.get_guild(906519554119839794)
        self.init_checkPatch.start()
        self.init_tasks.start()
        self.init_checkOnline.start()

    @commands.Cog.listener()
    async def on_ready(self):
        log.info(f'Logged in as: {self.bot.user.name} - {self.bot.user.id} | Version: {discord.__version__}\n')

    @tasks.loop(seconds=0.95)
    async def init_checkOnline(self):
        channel = self.bot.get_channel(1010140976465059871)
        if channel is not None:
            query = "SELECT COUNT(*) OnlineCount FROM DNMembership.dbo.DNAuth WHERE CertifyingStep = 1 OR CertifyingStep = 2"
            data = await self.bot.db.execute(query)
            result = json.loads(data)

            if await self.checkIfProcessRunning('DNVillageServerRX64_TW.exe'):
                village = 'Online'
            else:
                village = 'Offline'

            if await self.checkIfProcessRunning('DNGameServerX64_TW.exe'):
                game = 'Online'
            else:
                game = 'Offline'

            embed = Embed()
            embed.title = 'Dragon Nest'
            embed.description = 'Game Server Status: **[**`{}`**]**\nVillage Server Status: **[**`{}`**]**\nOnline Players: **[**`{}`**]**'.format(game, village, result[0])
            embed.set_footer(text = today, icon_url="")
            if not await channel.history(limit=1).flatten():
                await channel.send(embed = embed)
            else:
                msg_id = await channel.history(limit=1).flatten()
                msg = await channel.fetch_message(msg_id[0].id)
                await msg.edit(embed = embed)

    async def checkIfProcessRunning(self, processName):
        for proc in psutil.process_iter():
            try:
                if processName.lower() in proc.name().lower():
                    return True
            except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
                pass
        return False;

    @tasks.loop(seconds=0.95)
    async def init_tasks(self):
        guild = self.bot.get_guild(906519554119839794)
        if guild is not None:
            users = len([m for m in guild.members if not m.bot])
            bots = len([m for m in guild.members if m.bot])
            #print(f"Users: {users} | Bots: {bots}")
            await self.bot.get_channel(906901793110372404).edit(name=f'Members: {users}')
            await self.bot.get_channel(907127531088519269).edit(name=f'Bots: {bots}')
    
    @tasks.loop(seconds=0.95)
    async def init_checkPatch(self):
        webPatch = await self.init_CheckWebPatchVersion()
        textPatch = await self.init_CheckTextPatchVersion()
        channel = self.bot.get_channel(1003588635741917215)
        
        if webPatch == textPatch:
            pass
        elif webPatch < textPatch:
            log.info(f'Web Patch Version {webPatch} is lower than in Text Patch Version {textPatch}')
            pass
        elif webPatch > textPatch:
            log.info(f'Server has been updated from {textPatch} to {webPatch}')
            
            embed = Embed(color=Colour.random())
            embed.title = 'Dragon Nest'
            embed.description = '**Dragon Nest Adventure** has been patched from {} to {}'.format(str(textPatch), str(webPatch))
            embed.set_footer(text = today, icon_url="")
            await channel.send(embed = embed)
            
            await self.init_updateTextPatchVersion(webPatch)
    
    async def init_CheckWebPatchVersion(self):
        onlinePatchVersion = urllib.request.urlopen("http://127.0.0.1/Patch/PatchInfoServer.cfg").read().decode("ASCII")
        onlinePatchVersionINT = re.sub("Version ", "", onlinePatchVersion)
        
        return int(onlinePatchVersionINT)

    async def init_CheckTextPatchVersion(self):
        cfgVersion = open('extra\\Patch\\PatchInfoServer.cfg', 'r').read()
        cfgVersionINT = re.sub("Version ", "", cfgVersion)
        return int(cfgVersionINT)

    async def init_updateTextPatchVersion(self, version):
        cfgVersion = open('extra\\Patch\\PatchInfoServer.cfg', 'w')
        cfgVersion.write(f'Version {version}')
        cfgVersion.close()

def setup(bot):
    bot.add_cog(Event(bot))
