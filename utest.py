#https://docs.python.org/2/library/unittest.html
import unittest

class Useless:
  pass

class StillUseless:
  pass

class Test(unittest.TestCase):
  def test_this_test_will_pass(self):
    self.assertEqual(2, 2, msg="assertEqual")

  def test_not_equal(self):
    self.assertNotEqual(2, 3)

  def test_equality(self):
    self.assertTrue(2 == 2)

  def test_false(self):
    self.assertFalse(2 == 3)

  def test_Is(self):
    useless = Useless()
    self.assertIs(useless, useless)

  def test_not_is(self):
    useless = Useless()
    self.assertIsNot(useless, Useless())

  def test_none(self):
    self.assertIsNone(None)

  def test_not_none(self):
    self.assertIsNotNone(Useless())

  def test_not_none(self):
    self.assertIsNotNone(Useless())

  def test_in(self):
    self.assertIn("hello", ["not here", "not here too", "hello"])

  def test_not_in(self):
    self.assertNotIn("where", ["is", "waldo"])

  def test_is_instance(self):
    useless = Useless()
    self.assertIsInstance(useless, Useless)

  def test_is_not_instance(self):
    useless = Useless()
    self.assertNotIsInstance(useless, StillUseless) 

#class NewVisitorTest(unittest.TestCase):
#  def setUp(self):
#    self.browser = webdriver.Firefox() 
#
#  def setDown(self):
#    self.browser.quit()
#
#  def test_can_start_a_list_and_retrive_it_later(self):
#    self.browser.get('http://localhost:8000')
#
#    self.assertIn('To-Do', self.browser.title)
#    self.fail('Finish the test!')
#
if __name__ == '__main__':
  unittest.main()
