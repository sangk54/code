/* main.cpp -- main module
 *
 *			Ryan McDougall -- 2009
 */

#include <iostream>
#include <main.h>

using namespace std;


//=============================================================================

Ogre::Root *render_setup (int width, int height)
{
    Ogre::Root *root = new Ogre::Root("Data/plugins.cfg", "Data/ogre.cfg", "Data/ogre.log");

    if (!root->restoreConfig()) 
    {
        // setup a renderer
        Ogre::RenderSystemList *renderers = root-> getAvailableRenderers();
        assert (!renderers-> empty()); // we need at least one renderer to do anything useful

        //Ogre::RenderSystem *renderSystem = chooseRenderer(renderers);
        Ogre::RenderSystem *renderSystem = *renderers-> begin();
        assert (renderSystem); // user might pass back a null renderer, which would be bad!

        root-> setRenderSystem (renderSystem);

        QString dimensions = QString ("%1x%2").arg (width).arg (height);
        renderSystem-> setConfigOption ("Video Mode", dimensions.toStdString());

        // initialize without creating window
        root-> getRenderSystem()-> setConfigOption("Full Screen", "No");
        root-> saveConfig();
    }

    root-> initialise (false);

    // Load resource paths from config file
    Ogre::ConfigFile config;
    config.load ("Data/resources.cfg");

    // Go through all sections & settings in the file
    Ogre::ConfigFile::SectionIterator it = config.getSectionIterator();

    Ogre::String secName, typeName, archName;
    while (it.hasMoreElements()) 
    {
        secName = it.peekNextKey();
        Ogre::ConfigFile::SettingsMultiMap *settings = it.getNext();
        Ogre::ConfigFile::SettingsMultiMap::iterator i;

        for (i = settings->begin(); i != settings->end(); ++i) 
        {
            typeName = i->first;
            archName = i->second;
            Ogre::ResourceGroupManager::getSingleton().addResourceLocation (archName, typeName, secName);
        }
    }
            
    Ogre::ResourceGroupManager::getSingleton().initialiseAllResourceGroups();

    return root;
}

//=============================================================================
// Main entry point
int
main (int argc, char** argv)
{
    QApplication app (argc, argv);
    
    QWidget *win1 = new QWidget;
    QVBoxLayout *layout = new QVBoxLayout (win1);
    
    TestWidget *win3d = new TestWidget (render_setup (100, 100), win1);
    //Scene *scene = new Scene (win3d);
    layout-> addWidget (win3d);

    //QLineEdit *line = new QLineEdit ();
    //layout-> addWidget (line);

    win1-> setMinimumSize (100, 100);
    win1-> setLayout (layout);
    win1-> show ();

    QGraphicsScene scene;
    QGraphicsView view (&scene);

    scene.addWidget (new QDialog ());
    scene.addWidget (new QLineEdit ());

    //view.show();

    return app.exec ();
}