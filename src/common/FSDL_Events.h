//
//  FSDL_Events.h
//  love
//
//  Created by john on 12-1-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#ifndef love_FSDL_Events_h
#define love_FSDL_Events_h

#include <queue>

#define FSDL_BUTTON(X)           (1 << ((X)-1))
#define FSDL_BUTTON_LEFT         1
#define FSDL_BUTTON_MIDDLE       2
#define FSDL_BUTTON_RIGHT        3
#define FSDL_BUTTON_WHEELUP      4
#define FSDL_BUTTON_WHEELDOWN    5
#define FSDL_BUTTON_X1           6
#define FSDL_BUTTON_X2           7
#define FSDL_BUTTON_LMASK        SDL_BUTTON(SDL_BUTTON_LEFT)
#define FSDL_BUTTON_MMASK        SDL_BUTTON(SDL_BUTTON_MIDDLE)
#define FSDL_BUTTON_RMASK        SDL_BUTTON(SDL_BUTTON_RIGHT)
#define FSDL_BUTTON_X1MASK       SDL_BUTTON(SDL_BUTTON_X1)
#define FSDL_BUTTON_X2MASK       SDL_BUTTON(SDL_BUTTON_X2)

typedef enum {
    FSDL_NOEVENT = 0,
    FSDL_MOUSEBUTTONDOWN,
    FSDL_MOUSEBUTTONUP,
    FSDL_QUIT
} FSDL_EventType;

typedef struct {
    int x;
    int y;
    unsigned short button;
} FSDL_MouseEvent;

typedef struct {
    unsigned char type;
    FSDL_MouseEvent mouse;
} FSDL_Event;

extern int FSDL_PollEvent(FSDL_Event *event);
extern int FSDL_PushEvent(FSDL_Event *event);
extern int FSDL_WaitEvent(FSDL_Event *event);
extern std::queue<FSDL_Event*> msgQ;

#endif
