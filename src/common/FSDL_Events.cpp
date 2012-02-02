//
//  FSDL_Events.cpp
//  love
//
//  Created by john on 12-1-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#include "FSDL_Events.h"

std::queue<FSDL_Event*> msgQ;

int FSDL_PollEvent(FSDL_Event *event)
{
    int i = msgQ.size();
    if(msgQ.size() >0)
    {
        FSDL_Event* tmp = msgQ.front();
        memcpy(event, tmp, sizeof(*tmp));
        //event = msgQ.front();
        msgQ.pop();
    }
    return i;
}

int FSDL_PushEvent(FSDL_Event *event)
{
    msgQ.push(event);
    return msgQ.size();
}

int FSDL_WaitEvent(FSDL_Event *event){
    int i = 0;//
}
