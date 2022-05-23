from urllib.request import urlopen
from bs4 import BeautifulSoup
import unittest
import requests
page = requests.get("http://localhost:8080")

soup = BeautifulSoup(page.content, 'html.parser')
print(soup.prettify())

print("===SPACER1===")

print(soup.find(id="indices-and-tables"))

indices = soup.find(id="indices-and-tables")

print("===SPACER2===")

print(indices.h1.prettify())

print("===SPACER3===")

print(indices.h1.get_text())


print("====== SPACER FOR TEST CASES ======")

class Test(unittest.TestCase):
   bs = None
   def setUpClass():
      #url = '<a target="_blank" rel="nofollow" href="https://en.wikipedia.org/wiki/Python">https://en.wikipedia.org/wiki/Python</a>'
      #url = '<a target="_blank" rel="nofollow" href="http://localhost:8080">http://localhost:8080</a>'
      url = 'http://localhost:8080'
      Test.bs = BeautifulSoup(urlopen(url), 'html.parser')
   def test_titleText(self):
      pageTitle = Test.bs.find('h1').get_text()
      self.assertEqual('Post-Graduate DevOps Program Capstone¶', pageTitle);
   def test_contentExists(self):
      #content = Test.bs.find('div',{'section id':'indices-and-tables'})
      content = Test.bs.find(id="indices-and-tables")
      self.assertIsNotNone(content)
if __name__ == '__main__':
   unittest.main()

