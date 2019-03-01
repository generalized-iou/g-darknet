# Call hierarchy

- Thread management, for each thread:
  - `train_network_datum(net)`
    - `forward_network(net)`, calls `_gpu` version, if available
      - see loss implementation for details of `forward_yolo_layer`
      - cost is averaged across all layers with cost (`yolo_layer` in the case of yolov3)
    - `backward_network(net)`, calls `_gpu` version, if available
    - `float error = *net->cost`
    - `if(((*net->seen)/net->batch)%net->subdivisions == 0) update_network(net)`
    - `return error`

# Definition

![loss](/assets/img/loss-yolov2.png?raw=true)

See: https://stats.stackexchange.com/questions/287486/yolo-loss-function-explanation#answer-287497

# yolov2 vs yolov3

- first 2 terms are the same (x,y center & w,h)

- the last three terms in YOLO v2 are the squared errors, whereas in YOLO v3, they’ve been replaced by cross-entropy error terms. In other words, object confidence and class predictions in YOLO v3 are now predicted through logistic regression.

See: https://towardsdatascience.com/yolo-v3-object-detection-53fb7d3bfe6b

# Loss implementation

from yolov3.pdf: "During training we use sum of squared error loss."

Note:
 - `detection_layer.c` contains the losses for v1
 - `region_layer.c` contains the losses for v2
   - v2 adds anchor boxes (k-means cluster results)

- in `yolo_layer.c` (v3) (detection layers are used only on yolov1), `forward_yolo_layer`:
  - for (b = 0; b < l.batch; ++b)
    - for (j = 0; j < l.h; ++j)
      - for (i = 0; i < l.w; ++i)
        - for (n = 0; n < l.n; ++n)
          - 


Pytorch implementation:

    def compute_iou(output, target):
        x1 = output[:, 0]
        y1 = output[:, 1]
        x2 = output[:, 2]
        y2 = output[:, 3]
        x2 = torch.max(x2, x1)
        y2 = torch.max(y2, y1)

        x1g = target[:, 0]
        y1g = target[:, 1]
        x2g = target[:, 2]
        y2g = target[:, 3]

        xkis1 = torch.max(x1, x1g)
        ykis1 = torch.max(y1, y1g)
        xkis2 = torch.min(x2, x2g)
        ykis2 = torch.min(y2, y2g)

        xc1 = torch.min(x1, x1g)
        yc1 = torch.min(y1, y1g)
        xc2 = torch.max(x2, x2g)
        yc2 = torch.max(y2, y2g)

        intsctk = torch.zeros(x1.size()).to(output)
        mask = (ykis2 > ykis1) * (xkis2 > xkis1)
        intsctk[mask] = (xkis2[mask] - xkis1[mask]) * (ykis2[mask] - ykis1[mask])
        unionk = (x2 - x1) * (y2 - y1) + (x2g - x1g) * (y2g - y1g) - intsctk
        iouk = intsctk / unionk

        area_c = (xc2 - xc1) * (yc2 - yc1)
        miouk = iouk - ((area_c - unionk) / area_c)
        return iouk, miouk


    def miou(output, target):
        return (1 - compute_iou(output, target)[1]).mean()


    def iou(output, target):
        return (1 - compute_iou(output, target)[0]).mean()
