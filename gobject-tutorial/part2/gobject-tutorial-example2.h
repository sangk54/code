/* Insert GPL header. */

#ifndef _GOBJECT_TUTORIAL_EXAMPLE2_H_
#define _GOBJECT_TUTORIAL_EXAMPLE2_H_

/* Our "Instance struct" defines all the data fields that make our object unique. */
typedef struct _SomeObject SomeObject;
struct _SomeObject
{
	GObject		parent_obj;

	/* Some useful fields may follow. */
};

/* Our "Class struct" defines all the method functions that our objects will share. */
typedef struct _SomeObjectClass SomeObjectClass;
struct _SomeObjectClass
{
	GTypeClass	parent_class;

	/* Some useful methods may follow. */
};

/* This method returns the GType associated with our new object type. */
GType	some_object_get_type (void);

/* These are the Class/Instance Initialize/Finalize functions. Their signature is determined in gtype.h. */
void	some_object_class_init		(gpointer g_class, gpointer class_data);
void	some_object_class_final		(gpointer g_class, gpointer class_data);
void	some_object_instance_init	(GTypeInstance *instance, gpointer g_class);

/* These are the GObject Construct/Destroy methods. Their signatures are determined in gobject.h. */
GObject* some_object_constructor (GType self_type, guint n_properties, GObjectConstructParam *properties);
void	some_object_dispose (GObject *self);
void	some_object_finalize (GObject *self);

/* These are the GObject Get and Set Property methods. Their signatures are determined in gobject.h. */
void	some_object_get_property (GObject *object, guint property_id, GValue *value, GParamSpec *pspec);
void	some_object_set_property (GObject *object, guint property_id, const GValue *value, GParamSpec *pspec);

/* Handy macros */
#define SOME_OBJECT_TYPE		(some_object_get_type ())
#define SOME_OBJECT(obj)		(G_TYPE_CHECK_INSTANCE_CAST ((obj), SOME_OBJECT_TYPE, SomeObject))
#define SOME_OBJECT_CLASS(c)		(G_TYPE_CHECK_CLASS_CAST ((c), SOME_OBJECT_TYPE, SomeObjectClass))
#define SOME_IS_OBJECT(obj)		(G_TYPE_CHECK_TYPE ((obj), SOME_OBJECT_TYPE))
#define SOME_IS_OBJECT_CLASS(c)		(G_TYPE_CHECK_CLASS_TYPE ((c), SOME_OBJECT_TYPE))
#define SOME_OBJECT_GET_CLASS(obj)	(G_TYPE_INSTANCE_GET_CLASS ((obj), SOME_OBJECT_TYPE, SomeObjectClass))

#endif
