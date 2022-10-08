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

class Admin(commands.Cog):
    """
    Admin Commands
    """

    def __init__(self, bot):
        self.bot = bot

    @commands.command()
    @commands.has_permissions(administrator=True)
    async def clear(self, ctx):
        """Purge entire Conversation in a channel"""
        await ctx.message.delete()
        await ctx.channel.purge()

    @commands.command(pass_context=True)
    @commands.has_permissions(administrator=True)
    async def clean(self, ctx, channel_id):
        """Purge entire Channel Conversation"""
        channel = self.bot.get_channel(int(channel_id))
        await ctx.message.delete()
        await channel.purge()
    
    @commands.command()
    @commands.has_permissions(administrator=True)
    async def servers(self, ctx):
        """Command which shows the total amount of server and users"""
        await ctx.message.delete()

        guilds = len(self.bot.guilds)
        users = sum(g.member_count for g in self.bot.guilds)

        embed = discord.Embed(color=discord.Colour(0x00ff00))
        embed.description = '**Total servers:** {0}\n**Total users:** {1}'.format(guilds, users)

        await ctx.send(embed=embed, delete_after=30)
        
def setup(bot):
    bot.add_cog(Admin(bot))