//
//  main.m
//  ImageToTexture
//
//  Created by David Reed on 4/1/11.
//  Copyright 2011 www.dave256apps.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

void saveAsTexture(NSBitmapImageRep *imageRep, NSString *filename)
{
    
    if (![imageRep isPlanar]) {
        NSUInteger width = [imageRep pixelsWide];
        NSUInteger height = [imageRep pixelsHigh];
        unsigned char *data = [imageRep bitmapData];
        
        NSUInteger bpp = [imageRep bitsPerPixel];
        NSUInteger bytes = bpp / 8;
        NSInteger i;

        printf("%s\n", [filename cStringUsingEncoding:NSUTF8StringEncoding]);
        FILE *fp = fopen([filename cStringUsingEncoding:NSUTF8StringEncoding], "w");
        if (bpp == 24) {
            printf("3, %ld, %ld, GL_RGB, GL_UNSIGNED_BYTE\n", width, height);
        }
        else if (bpp == 32) {
            printf("4, %ld, %ld, GL_RGBA, GL_UNSIGNED_BYTE\n", width, height);
        }
        
        // save vertically flipped for OpenGL texture
        for (i=height-1; i>=0 ; --i) {
            unsigned char *p = &data[i*width*bytes];
            fwrite(p, sizeof(unsigned char), width * bytes, fp);
        }
        fclose(fp);
    }
    else {
        fprintf(stderr, "image is planar, not meshed; texture file not generated");
    }
}

int main (int argc, const char * argv[])
{

    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    NSBitmapImageRep *imageRep;
    char cFilename[1024];
    NSUInteger len;
                   
    NSString *filename, *outFilename;
    
    if (argc < 2) {
        printf("Enter filename: ");
        fgets(cFilename, 1024, stdin);

        // remove \n from string
        len = strlen(cFilename);
        cFilename[len-1] = '\0';
        
        filename = [NSString stringWithCString:cFilename encoding:NSUTF8StringEncoding];
    }
    else {
        // use command line argument
        filename = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
    }

    printf("reading: %s\n", [filename cStringUsingEncoding:NSUTF8StringEncoding]);
    outFilename = [[filename stringByDeletingPathExtension] stringByAppendingPathExtension:@"tex"];

    imageRep = [NSBitmapImageRep imageRepWithContentsOfFile:filename];
    if (imageRep) {
        saveAsTexture(imageRep, outFilename);
    }
    else {
        fprintf(stderr, "error reading file\n");
    }
    [pool drain];
    return 0;
}

