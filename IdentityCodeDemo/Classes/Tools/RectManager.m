//
//  RectManager.m
//  IdentityCodeDemo
//
//  Created by 西太科技 on 2017/4/6.
//  Copyright © 2017年 lei wenhao. All rights reserved.
//

#import "RectManager.h"

char numbers[256];
CGRect rects[64];

@implementation RectManager

+ (CGRect)getEffectImageRect:(CGSize)size {
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    CGPoint point;
    
    if (size.width / size.height > screenSize.width / screenSize.height) {
    
        float oldW = size.width;
        size.width = screenSize.width / size.height * size.height;
        point.x = (oldW - size.width) / 2;
        point.y = 0;
    
    } else {
        
        float oldH = size.height;
        size.height = screenSize.height / screenSize.width * size.width;
        point.x = 0;
        point.y = (oldH - size.height) / 2;
    }
    
    CGRect rect = CGRectMake(point.x, point.y, size.width, size.height);
    
    return rect;
}

+ (CGRect)getGuideFrame:(CGRect)rect {
    
    float previewWidth = rect.size.height;
    float previewHeight = rect.size.width;
    
    float cardH, cardW;
    float left, top;
    
    cardW = previewWidth * 70 / 100;
    
    if (previewWidth < cardW) {
        cardW = previewWidth;
    }
    
    cardH = (int)(cardW / 0.63084f);
    
    left = (previewWidth - cardW) / 2;
    top = (previewHeight - cardH) / 2;
    
    CGRect guideFrame = CGRectMake(top + rect.origin.x, left + rect.origin.y, cardH, cardW);
    
    return guideFrame;
}

+ (int)docode:(unsigned char *)pbBuf len:(int)tLen {
    
    int hic, lwc;
    int i, j, code;
    int x, y, w, h;
    int charCount = 0;
    
    int charNum = 0;
    char szBankName[128];
    
    i = 0;
    hic = pbBuf[i++];
    lwc = pbBuf[i++];
    code = (hic << 8) + lwc;
    
    hic = pbBuf[i++];
    lwc = pbBuf[i++];
    code = (hic << 8) + lwc;
    
    for (j = 0; j < 64; ++j) {
        szBankName[j] = pbBuf[i++];
    }
    
    hic = pbBuf[i++];
    lwc = pbBuf[i++];
    code = (hic << 8) + lwc;
    
    charNum = code;
    
    while (i < tLen - 9) {
        
        hic = pbBuf[i++];
        lwc = pbBuf[i++];
        x = (hic << 8) + lwc;
        
        numbers[charCount] = (char)x;
        
        hic = pbBuf[i++];
        lwc = pbBuf[i++];
        x = (hic << 8) + lwc;
        
        hic = pbBuf[i++];
        lwc = pbBuf[i++];
        y = (hic << 8) + lwc;
        
        hic = pbBuf[i++];
        lwc = pbBuf[i++];
        w = (hic << 8) + lwc;
        
        hic = pbBuf[i++];
        lwc = pbBuf[i++];
        h = (hic << 8) + lwc;
        
        rects[charCount] = CGRectMake(x, y, w, h);
        
        charCount++;
    }
    
    numbers[charCount] = 0;
    
    if (charCount < 10 || charCount > 24 || charNum != charCount) {
        charCount = 0;
    }
    
    return charCount;
}

+ (CGRect)getCorpCardRect:(int)width height:(int)height guideRect:(CGRect)guideRect charCount:(int)charCount {
    
    CGRect subRect = rects[0];
    
    int i = 0;
    int nAvgW = 0;
    int nAvgH = 0;
    int nCount = 0;
    
    nAvgW = rects[0].size.width;
    nAvgH = rects[0].size.height;
    nCount = 1;
    
    for (i = 1; i < charCount; ++i) {
        
        subRect = combinRect(subRect, rects[i]);
        
        if (numbers[i] != ' ') {
            nAvgW += rects[i].size.width;
            nAvgH += rects[i].size.height;
            nCount++;
        }
    }
    
    nAvgW /= nCount;
    nAvgH /= nCount;
    
    subRect.origin.x = subRect.origin.x + guideRect.origin.x;
    subRect.origin.y = subRect.origin.y + guideRect.origin.y;
    
    subRect.origin.y -= nAvgH;
    
    if (subRect.origin.y < 0) {
        subRect.origin.y = 0;
    }
    
    subRect.size.height += nAvgH * 2;
    if (subRect.size.height + subRect.origin.y >= height) {
        subRect.size.height = height - subRect.origin.y - 1;
    }
    
    subRect.origin.x -= nAvgW;
    if (subRect.origin.x < 0) {
        subRect.origin.x = 0;
    }
    
    subRect.size.width += nAvgW * 2;
    if (subRect.size.width + subRect.origin.x >= width) {
        subRect.size.width = width - subRect.size.width - 1;
    }
    
    return subRect;
}

+ (char *)getNumbers {
    return numbers;
}

CGRect combinRect (CGRect A, CGRect B) {
    
    CGFloat t, b, l, r;
    
    l = fminf(A.origin.x, B.origin.x);
    r = fmaxf(A.size.width + A.origin.x, B.size.width + B.origin.x);
    t = fminf(A.origin.y, B.origin.y);
    b = fmaxf(A.size.height + A.origin.y, B.size.height + B.origin.y);
    
    return CGRectMake(l, t, r - l, b - t);
}


@end
