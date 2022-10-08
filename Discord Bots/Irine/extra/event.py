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

    @commands.Cog.listener()
    async def on_ready(self):
        log.info(f'Logged in as: {self.bot.user.name} - {self.bot.user.id} | Version: {discord.__version__}\n')

        for filename in os.listdir('./commands'):
            if filename.endswith('.py'):
                try:
                    log.info(f'{filename[:-3]}.py successfully loaded.')
                except Exception as ex:
                    log.info(f'Could not load {filename[:-3]}. Reason: {ex}')

def setup(bot):
    bot.add_cog(Event(bot))
