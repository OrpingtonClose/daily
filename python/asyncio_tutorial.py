#http://www.stackabuse.com/python-async-await-tutorial/
#https://www.safaribooksonline.com/library/view/software-architecture-with/9781786468529/ch05s08.html
import asyncio, aiohttp, async_timeout

@asyncio.coroutine
def fetch_page(session, url, timeout=60):
  with async_timeout.timeout(timeout):
    response = session.get(url)
    return response

loop = asyncio.get_event_loop()
urls = ('http://www.google.com',
        'http://www.yahoo.com', 
        'http://twitter.com')
async def parse_response(futures):
  for future in futures:
    response = future.result()
    data = await response.text()
    print("="*20)
    print("Response: {}, data: {}".format(response.status, data[:50]))
    response.close()

session = aiohttp.ClientSession(loop=loop)
tasks = [fetch_page(session, url) for url in urls]
done, pending = loop.run_until_complete(asyncio.wait(tasks, timeout=120))

loop.run_until_complete(parse_response(done))
#https://github.com/nickoala/telepot/issues/378
#Just realized, aiohttp.ClientSession.close() has only become a coroutine a few months ago. I will also need to fix the aiohttp dependency.
session.close()
