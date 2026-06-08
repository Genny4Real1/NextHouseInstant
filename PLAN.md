# PLAN.md

## Added library

I added the library for the app colors exported directly from Figma. You can find it in C:\Users\Andrea\NextHouseInstant\flutter\lib\theme\app_colors.dart

## Errors

This section is written by the user and it shall not be modified. Here you can read the modifications requested by the user and eventual bugs that he wants to be fixed. Play close attention to these and then write the rest of PLAN.md to accomodate his requests. Only when the user is satisfied with the output of planning mode you can start building the implementation.  

* Modification 1: The timer actually starts when you click take a selfie not when the user presses the record button. In the figma design (https://www.figma.com/design/iHFUNecRDj8tJ5yBqHGPym/PrototypeDesign?node-id=29-4&m=dev) the user arrives at the camera screen, and only after pressing the record button (https://www.figma.com/design/iHFUNecRDj8tJ5yBqHGPym/PrototypeDesign?node-id=33-6&m=dev) he can reach the next screen where the timer starts and at the end of it flashes and takes the photo as you can see in the prototype (https://www.figma.com/design/iHFUNecRDj8tJ5yBqHGPym/PrototypeDesign?node-id=131-144&m=dev). Please implement these functionalities, including the pressing of the button and the animation of the button disappearing like in a real camera mode and the record button make it as close as possible to the figma design.  

* Modification 2: new logo, implement the new logo starting from this component https://www.figma.com/design/iHFUNecRDj8tJ5yBqHGPym/PrototypeDesign?node-id=257-209&m=dev
in this case be as close as possible to the originial design from Figma and use it in the first screen as per figma design https://www.figma.com/design/iHFUNecRDj8tJ5yBqHGPym/PrototypeDesign?node-id=1-2&m=dev.  

* Bug 1: When taking multiple photos, while in the processing screen, the stock image is visible. That's not expected behaviour and you should look into it to try to fix it.

* Bug 2: In tests on my tablet, the share and delete button texts overflow by 18 pixels (there is also a visible error message). There is clearly space available so it shouldn't overflow. Plese fix it.

* Bug 3: When in gallery screen, the arrows should only permit you to navigagte through the images horizontally and starting from the first (leftmost position) until the last (rightmost position) https://www.figma.com/design/iHFUNecRDj8tJ5yBqHGPym/PrototypeDesign?node-id=113-286&m=dev. Right now, if you're at the first photo, if you use the arrow to go left it goes back to the last image, and that's not intended behaviour. If there are no more pictures on the left or right of the image it should be grayed out to signal that there is no more interaction and not do anything.  

* Modification 3: in the selection screen, make the text above not collide with the images.

* Modification 4: in the selection screen, show only the grid with the photos you can select (and don't forget the checkmark). In the figma design, the prototype screen had placeholder blank images instead of real ones to show how would the grid look like. But in the final prototype, the grid should be as big as the number of images, with a maximum of 4 x 3. If there are more than 12 photos, it should create a page with the same behaviour starting from the 13th image and so on.

* Modification 5: in the selection screen, make the Done button be on the bottom center of the screen, for visibility and clarity.

* Bug 4: In the final processing screen, if there is only one photo it is shown that one with one of the stock images. The expected behavior is the following: if you only have one photo, you just show it in the background blurred like the first processing screen (obviously they are different pictures because the first one was the 'raw' camera photo and the second one is the final result made by the user). The images should be arranged in a endless auto-scrolling animation that stays in loop for the duration of the screen. Please implement these.

* Bug 5: In the final QR scene, the prop QR changes rapidly and the progress bar to represent the time left to scan it is not visible. Please implement the progress bar and make the prop QR not change. For now the prop QR does not to connect to anythingm just show that it's there.

REMEMBER: DON NOT EDIT ANYTHING ABOVE THIS LINE.  