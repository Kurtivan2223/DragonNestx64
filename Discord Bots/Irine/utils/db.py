import logging
import aioodbc
from discord.ext import commands
import json

from utils import default

config = default.get_config()
log = logging.getLogger()

class Database(commands.Cog):
    def __init__(self, bot):
        self.bot = bot
        self.bot.loop.create_task(self.init_conn())
        self.bot.db = self

    async def init_conn(self):
        log.info("Connecting to database...")

        db_host = config.get('DATABASE', 'db-host')
        db_name = config.get('DATABASE', 'db-name')
        db_user = config.get('DATABASE', 'db-user')
        db_pass = config.get('DATABASE', 'db-pass')
        dsn = 'DRIVER=SQL Server;SERVER='+db_host+';DATABASE='+db_name+';UID='+db_user+';PWD='+ db_pass
        try:
            self.bot.pool = await aioodbc.create_pool(dsn=dsn, autocommit=True, loop=self.bot.loop)
        except Exception as ex:
            log.critical(f'Could not connect to database. Reason: {ex}')
            exit()
        else:
            log.info("Successfully Connected to database.")

    async def execute(self, query, params=None, single=False, rowcount=False):
        async with self.bot.pool.acquire() as conn:
            async with conn.cursor() as cur:
                await cur.execute(query, params or ())
                
                if rowcount:
                    return cur.rowcount
                elif single:
                    return await cur.fetchone()
                else:
                    data = await cur.fetchall()
                    for row in data:
                        result = json.dumps([x for x in row])
                    return result

def setup(bot):
    bot.add_cog(Database(bot))