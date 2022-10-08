import logging
import os
import discord
from discord.ext import commands
from datetime import datetime
from utils import default

folder = os.path.isdir('logs')
if not folder:
    print('"Logs" folder doesn`t exists! Creating folder....')
    os.mkdir('logs')
    print('Success fully Created "Logs" folder')
else:
    pass

logging.basicConfig(format='%(asctime)s [%(filename)14s:%(lineno)4d][%(funcName)30s][%(levelname)8s] %(message)s', level=logging.INFO)

fileHandler = logging.FileHandler(filename='logs/' + '{:%Y-%m-%d}.log'.format(datetime.now()))

formatter = logging.Formatter('%(asctime)s [%(filename)14s:%(lineno)4d][%(levelname)8s] %(message)s')
fileHandler.setFormatter(formatter)

log = logging.getLogger()
log.addHandler(fileHandler)

config = default.get_config()

initial_extensions = ['extra.event',
                    'utils.nest',
                    'utils.quest',
                    'utils.items']

intents = discord.Intents.default()
intents.members = True

bot = commands.Bot(command_prefix=config['SETTINGS']['prefix'],
                   intents=intents,
                   activity=discord.Game(name='Dragon Nest', type=1))
bot.remove_command('help')


if __name__ == '__main__':
    for extension in initial_extensions:
        bot.load_extension(extension)

    if config.getboolean('TOKEN', 'is-developing'):
        log.info("Running with Development token")
        TOKEN = config['TOKEN']['dev-token']
    else:
        log.info("Running with Production token")
        TOKEN = config['TOKEN']['prod-token']

    bot.run(TOKEN)