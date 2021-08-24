#sudo apt-get install libavformat-dev libavutil-dev libswscale-dev libv4l-dev libglew-dev libgtk2.0-dev python3-opencv -y
import cv2 
cap = cv2.VideoCapture(0)
if not (cap.isOpened()):
  print('Could not open video device')
  cap.set(cv2.cv.CV_CAP_PROP_FRAME_WIDTH, 640)
  cap.set(cv2.cv.CV_CAP_PROP_FRAME_HEIGHT, 480)

while(True):
  ret, frame = cap.read()
  cv2.imshow('preview',frame)
  if cv2.waitKey(1) & 0xFF == ord('q'):
    break


cap.release()

cv2.destroyAllWindows()
