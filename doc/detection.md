# Call Examples

VOC

    ./darknet detector test cfg/voc.data cfg/yolov3-voc.cfg backup/baseline2/yolov3-voc.backup datasets/voc/VOCdevkit/VOC2007/JPEGImages/002130.jpg -out 002130

COCO

    ./darknet detector test cfg/coco.data cfg/yolov3.cfg backup/coco-baseline/yolov3.backup datasets/voc/VOCdevkit/VOC2007/JPEGImages/002130.jpg -out 002130

# Call hierarchy

  - `run_detector`
    - `test_detector`
      - `image im = load_image_color(input,0,0)`
      - `image sized = letterbox_image(im, net->w, net->h)`
      - `layer l = net->layers[net->n-1]`
      - `float *X = sized.data`
      - `network_predict(net, X)`
      - `int nboxes = 0`
      - `detection *dets = get_network_boxes(net, im.w, im.h, thresh, hier_thresh, 0, 1, &nboxes)`
      - `if (nms) do_nms_sort(dets, nboxes, l.classes, nms)`
      - `draw_detections(im, dets, nboxes, thresh, names, alphabet, l.classes)`
        - calculates abs box coordinates and draws to an opencv image

# Network output to bounding boxes

  - `get_yolo_detections` converts output to network to a `detection` object with bounding boxes and class probabilities
    - also applies threshold to classes
    - bounding boxes are "relative" to __ up to this point
    - detections are passed `correct_yolo_boxes` which will:
      - move and scale the x,y,w,h values to the incoming image dimensions
